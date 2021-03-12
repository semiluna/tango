# West Cambridge Airfreight
You can see the project in action through the following steps:
- Install MATLAB R2020b with the following add-ons:
    - Stateflow
    - Navigation Toolbox
    - Aerospace Blockset
    - UAV Toolbox Interface for Unreal Engine Projects
    - UAV Toolbox
    - Symbolic Math Toolbox
    - Statistics and Machine Learning Toolbox
    - Simulink
    - Optimization Toolbox
    - Global Optimization Toolbox
    - Control System Toolbox
    - Aerospace Toolbox

- Download the compressed Unreal Engine 4 files for the West Cambridge model: [Unreal Engine Files](https://drive.google.com/file/d/1Ber-ijlNWq_2KG_vf-q5FondLhobsCU2/view?usp=sharing)  
  (This was too large to put in the submission repository)
- Extract the contents of this file

- Open the project folder in MATLAB
- Open the `UAVPackageDelivery.prj` project in Simulink by double clicking it in the file explorer
- Navigate to and double click on the `Simulation 3D Scene Configuration 1` block in Simulink:  
  `uavPackageDelivery->External Sensors - Lidar & Camera->SimulationEnvironmentVariant->PhotorealisticQuadrotor`
- Ensure the value of the `Scene source` parameter is `Unreal Executable`
- Change the value of the `File name` parameter to the path of the Unreal Engine 4 executable you downloaded earlier
  `WindowsNoEditor->MyProject.exe`
- Type `westCambridgeTango` into the MATLAB command window to run the preparation shortcut
- After the UI window opens, run the model from the Simulink window (green button at the top)
- Wait for the photorealistic simulation to appear before attempting to upload any missions