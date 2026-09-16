import runpod
import json
import urllib.request
import urllib.parse
import subprocess
import time
import base64
import os
import uuid
import requests

# Start ComfyUI in the background
def start_comfyui():
    print("Starting ComfyUI...")
    subprocess.Popen([
        "python", "/workspace/ComfyUI/main.py", 
        "--disable-auto-launch", 
        "--port", "8188"
    ])
    
    # Wait until ComfyUI is ready to accept requests
    while True:
        try:
            response = requests.get("http://127.0.0.1:8188/system_stats")
            if response.status_code == 200:
                print("ComfyUI is ready!")
                break
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(1)

# Function to queue the prompt to ComfyUI
def queue_prompt(prompt_data):
    p = {"prompt": prompt_data}
    data = json.dumps(p).encode('utf-8')
    req = urllib.request.Request("http://127.0.0.1:8188/prompt", data=data)
    response = urllib.request.urlopen(req)
    return json.loads(response.read())

# Function to check if the generation is finished
def get_history(prompt_id):
    with urllib.request.urlopen(f"http://127.0.0.1:8188/history/{prompt_id}") as response:
        return json.loads(response.read())

# The main function that processes incoming RunPod requests
def handler(job):
    job_input = job['input']
    
    # 1. Extract the base64 image and prompt from the incoming API request
    input_image_b64 = job_input.get("image_base64")
    prompt_text = job_input.get("prompt", "default prompt text")
    
    # 2. Save the base64 image as a physical file in ComfyUI's input folder
    image_filename = f"input_{uuid.uuid4().hex}.png"
    image_path = os.path.join("/workspace/ComfyUI/input", image_filename)
    
    with open(image_path, "wb") as f:
        f.write(base64.b64decode(input_image_b64))

    # 3. Load your exported workflow JSON
    with open("/workspace/workflow_api.json", "r") as f:
        workflow = json.load(f)

  # =====================================================================
    # 4. INJECT YOUR DATA INTO THE WORKFLOW
    # =====================================================================
    # Node ID 8 is your "Load Image" node
    IMAGE_NODE_ID = "8" 
    workflow[IMAGE_NODE_ID]["inputs"]["image"] = image_filename

    # Node ID 3 is your Positive Prompt node
    PROMPT_NODE_ID = "3" 
    # Notice the key is "prompt", not "sample prompt"
    workflow[PROMPT_NODE_ID]["inputs"]["prompt"] = prompt_text
    # =====================================================================

    # 5. Send the workflow to ComfyUI
    print("Sending workflow to ComfyUI...")
    queued_prompt = queue_prompt(workflow)
    prompt_id = queued_prompt['prompt_id']

    # 6. Wait for ComfyUI to finish processing
    print(f"Processing prompt_id: {prompt_id}...")
    while True:
        history = get_history(prompt_id)
        if prompt_id in history:
            break
        time.sleep(1.5) # Poll every 1.5 seconds

    # 7. Find the output image in the history and convert it back to base64
    history_data = history[prompt_id]
    output_images = []
    
    for node_id in history_data['outputs']:
        node_output = history_data['outputs'][node_id]
        if 'images' in node_output:
            for image in node_output['images']:
                output_filename = image['filename']
                output_filepath = os.path.join("/workspace/ComfyUI/output", output_filename)
                
                with open(output_filepath, "rb") as f:
                    encoded_img = base64.b64encode(f.read()).decode('utf-8')
                    output_images.append(encoded_img)

    # 8. Return the base64 image back to the user via RunPod's API
    return {"status": "success", "images_base64": output_images}

# Start ComfyUI before starting the RunPod serverless listener
start_comfyui()
runpod.serverless.start({"handler": handler})
