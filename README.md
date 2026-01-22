# BMD-FusionExtras

FusionExtras brings QOL features to Blackmagic Design's compositing software Fusion to enhance the user experience. They can be used in both the **free** and paid versions of Davinci Resolve. 

This project is free and open source under the MIT License. 

# Features
All features support the ability to undo and redo. If something goes wrong you should be able to undo, to safely revert the action performed by a script. In case this does not work, please press `Shift + 0` to open the console and look for any red errors, and report the issue [here](https://github.com/Kartopod/BMD-FusionExtras/issues).  
If you would like to suggest improvements, ask questions or discuss anything about the project, you can create a new discussion [here](https://github.com/Kartopod/BMD-FusionExtras/discussions/)! 

## GLViewer_BlenderGrab, GLViewer_BlenderRotate, GLViewer_BlenderScale (Defaults: `G`, `R`, `S`)
With the viewer focused, press any of these shortcuts to enter the respective mode to grab, rotate or scale the selected tool(s) in the flow. Right clicking anywhere will revert the action and return the node to it's previous state. 

**Important: You will need to click on the viewer first to bring resolve's focus to the viewer, otherwise, the hotkey would be sent to the FlowView instead.**
![GL_ViewerGRSDemo1](https://github.com/user-attachments/assets/65333146-ee62-442c-ad06-c2b2f6e084eb)

You can use these shortcuts with multiple nodes selected to transform them together at once. Currently, these nodes will only be transformed with respect to their individual origins. 
![GL_ViewerGRSDemo2](https://github.com/user-attachments/assets/a7153a08-ead4-4b0d-9f45-80c1aa57a3d0)

_Notes:_ 
- Currently, there are no checks in place whether a mode is already activated, so you will need to take care to not press these shortcuts multiple times, or try to switch modes while one is already active. If you accidentally do this, simply right click a couple of times to revert the action(s). Undo if needed. 
- Currently, there is no support for constraining the transformation to a specific axis using X, Y, Z like in blender. This may come in the future. 


## Flow_AutoMerge (Default: `D`)
Automatically drops a merge node onto the _line_ directly below the selected node(s) and makes the necessary connections.
![Flow_AutoMerge](https://github.com/user-attachments/assets/5c41bd45-9d1e-4eaf-83a3-6f103c5e6a57)  

_Notes:_ 
- Currently **does not** have support for the 'Build flow vertically' option. i.e It will only look for a line **below** the selected node.

## Flow_BlenderGrab (Default: `G`)
Blender's G to grab functionality.  
With nodes selected, press the hotkey to start grab. Moving the mouse in this state will move the selected nodes. Left clicking anywhere will confirm the movement. Right clicking anywhere will cancel the grab action and revert the position(s) back.  
![Flow_BlenderGrab](https://github.com/user-attachments/assets/2c49aa7a-d5d8-4089-9c15-7ef72fb1f8aa)


## Flow_BlenderDupilcate (Default: `Shift + D`)
Blender's duplicate functionality.  
Duplicates selected nodes and grabs them automatically. Left clicking will confirm the duplication. **Unlike** blender, right clicking will cancel the duplication action entirely and delete the duplicate(s).  
![Flow_BlenderDuplicate](https://github.com/user-attachments/assets/d9552037-cba9-41b3-ab06-c4cbc7c301e3)

When duplicating single nodes, there is an issue where it might automatically add a merge node and mess things up. This is a limitation of the Fusion scripting API and sadly there doesn't seem to be a way to fix it. This issue only happens when you click on the node directly to select it. 
![Flow_BlenderDuplicate_Issue](https://github.com/user-attachments/assets/cc23614d-e5cb-4a50-81fe-eb54af097352)  
This happens because the dupilcate is being created at the position where you last click, and fusion tries to handle it automatically. To work around this, when selecting a single node to duplicate, **drag select** the node away from any other node, instead of clicking on it- this will make resolve register the click where you start the grab, which makes it work as intended.  
![Flow_BlenderDuplicate_Workaround](https://github.com/user-attachments/assets/9afa2a61-99c8-450c-852f-bcea9f360ff4)  

From my testing, this issue only occurs when trying to duplicate single nodes. Duplicating multiple nodes is unaffected.

## Flow_FunDelete (Default: `Ctrl + X`)
You may have noticed nodes springing outward when being deleted in the showcases above, that's thanks to this script! Pressing the hotkey will perform a **cut** action on the selected nodes, i.e. it will copy them to the clipboard and then delete them.  I personally use `Ctrl + X` for deleting anything at all (Even if I have no intention of copying to clipboard) since it is close to my left hand, and I don't have to look at my keyboard at all when deleting. Now whenever I delete anything, they bounce away, and I'll never grow tired of it. 
![Flow_FunDelete](https://github.com/user-attachments/assets/bf98aa5d-8f0e-4a5e-b5a2-6bb13af0f8cd)

If you don't want the deleted nodes to be copied to the clipboard, you can open the script manually and change the first variable's value to `false`:
```lua
local saveDeletedToClipboard = true -- Set to false to not save deleted tools to clipboard
```
The above would need to be changed to the following: 
```lua
local saveDeletedToClipboard = false -- Set to false to not save deleted tools to clipboard
```

## Flow_FunRunFromSelection (Default: `Shift + Ctrl + Alt + /`)
The least practical script in this project, but perhaps the most fun one. Pressing the hotkey will enable 'run mode', where any node you try to select will run away from you. You can pull a great prank on your friends! Right clicking will turn the mode off and revert the displaced nodes back to their original position. 
![Flow_FunRunFromSelection](https://github.com/user-attachments/assets/b52a44c9-72c4-46be-8223-523a7b1e2609)

*Note:* Would recommend that you do **NOT** run this script on anything important, just to be safe. 

# Supporting the project
If you find that the scripts are useful and would like to support the project, you can chuck a donation my way through Ko-fi!

[![Donate with Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/kartopod)

# Installation
- Click on the green **Code** button and then click on **Download ZIP**  
<img width="909" height="384" alt="image" src="https://github.com/user-attachments/assets/0cbf6c51-2989-4e78-8c37-e7b38081c370" />  

- Extract the .zip file's contents. This extracted folder will be referred to as 'The extracted source folder' in the following steps. 

- Open Davinci Resolve and open the Fusion page. Here, at the bottom right corner you should see a label showing you how much memory fusion is using up. Double click on the label to open the fusion preferences.
<img width="163" height="93" alt="image" src="https://github.com/user-attachments/assets/7caa7c78-13eb-4acd-b4f6-9fa5c160d942" />

- Navigate to the **Path Map** tab on the left, and look for the 'Scripts' entry under the 'From' section on the right. Right click on this entry and select the first option in the dropdown. This should open Fusion's scripts folder.  
<img width="1240" height="645" alt="image" src="https://github.com/user-attachments/assets/7a9c80dd-7de6-4095-9345-8f2249459491" />

- Go back to the extracted source folder, open the **scriptlib** folder and copy it's contents, paste them into the scripts folder that we opened previously.
- Go back to the extracted source folder, copy the entire **hotkey-scripts** folder and paste it into the scripts folder. Your scripts folder should now look something like this:
<img width="1188" height="692" alt="image" src="https://github.com/user-attachments/assets/ce3ca6f0-1f97-4cd4-bd76-825e1bc6e22d" />


- Finally, we need to set up keybinds so that the scripts run when they are pressed. Head back to the extracted source folder and find the aptly named **User.fu** file inside the **user** folder, copy it.
Go to the path map again in the fusion preferences. Under the 'System' toggle, right click the 'Profile' entry in the list and click on the first option. 
<img width="1151" height="630" alt="image" src="https://github.com/user-attachments/assets/dc88c757-5f46-420d-bd03-31ff58ed012d" />

- This will open the correct location to place the .fu file. You might already have a **User.fu** file present at this path. If you already know how to use .fu files, configure hotkeys for all the scripts in the hotkey-scripts folder. You can use the template for reference. If you've never used .fu files/there isn't already a **User.fu** file in that folder, you can simply paste the file that we copied in the previous step.  

- If you want to leave the keybinds as defaults provided with this project, you do not need to edit this file. You're all set! You should be able to use all the scripts provided in the project now. If you want to change the keybinds, read along. 


## Modifying the User.fu file
**Ensure that Davinci Resolve is closed before opening the User.fu file**
You can open the file using the text editor of your choice. 
Be very careful while modifying this file, misplacing even a single `{` will cause none of the hotkeys to work. If you don't know what you're doing, it is recommended to be extremely mindful of what you're adding and removing. 

```lua
{
	Hotkeys {
		Target = "FlowView",

		B = "AddTool{ id = 'Background' }",
		E = "AddTool{ id = 'EllipseMask' }",
		T = "AddTool{ id = 'Transform' }",
		R = "AddTool{ id = 'RectangleMask' }",
		P = "AddTool{ id = 'PolylineMask' }",
		M = "AddTool{ id = 'MediaIn' }",
		SHIFT_T = "AddTool{ id = 'TextPlus' }",
		CONTROL_M = "AddTool{ id = 'Merge' }",
	},

	Hotkeys {
		Target = "FlowView",

		D = "RunScript{ filename = 'Scripts:hotkey-scripts/Flow_AutoMerge.lua'}",
		G = "RunScript{ filename = 'Scripts:hotkey-scripts/Flow_BlenderGrab.lua'}",
		SHIFT_D = "RunScript{ filename = 'Scripts:hotkey-scripts/Flow_BlenderDuplicate.lua'}",
		CONTROL_X = "RunScript{ filename = 'Scripts:hotkey-scripts/Flow_FunDelete.lua'}",
		SHIFT_CONTROL_ALT_SLASH = "RunScript{ filename = 'Scripts:hotkey-scripts/Flow_FunRunFromSelection.lua'}",
		ALT_E = "RunScript{ filename = 'Scripts:hotkey-scripts/BatchEdit.lua'}",
	},
}
```
The template contains two **Hotkeys** sections, seperated for the sake of organization. The top one contains simple hotkeys that add the specified tool (node) into the flow when the hotkey is pressed. If you do not want these hotkeys, you can remove this section entirely:  
- Make sure that you remove starting from the `H` in the **first** 'Hotkeys', ending with the `},` of the **first** 'Hotkeys' section

The bottom section contains the hotkeys associated with the scripts. 

If you've placed the hotkey scripts in the correct location as described in the installation instructions, the template should already point to the correct path for each hotkey script. 

To change which hotkey is associated with a certain entry, you can use single character keys or a combination of modifier keys.
The format for entering modifier keys is **SHIFT_CONTROL_ALT_** followed by the name of the character. All characters must be uppercase, with the modifiers being seperated with underscores.  
Note that the order matters. 

Here are a few examples: 
```
SHIFT_CONTROL_ALT_A = ...,
SHIFT_CONTROL_A = ...,
SHIFT_ALT_A = ...,
CONTROL_ALT_A = ...,
CONTROL_A = ...,
A = ...,

SHIFT_SLASH = ...,
SHIFT_APOSTROPHE = ...,
```

Also ensure that every hotkey entry has a comma (,) at the end of the line. 

Save the file and open Fusion to test out the hotkeys. If nothing is happening, you may have made a mistake in configuring the **User.fu** file. Aptly named, since fusion gives you zero feedback about what you did wrong, so it is upto you to figure it out. If you are unable to figure out what went wrong, use the template again and be very careful about what you're changing. Incorrect addition/removal of a single character can mess it up.  
