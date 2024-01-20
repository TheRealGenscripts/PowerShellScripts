# PowerShell Scripts
A collection of simple but useful PowerShell scripts. (more to come soon)

| Script Name | Description |
| --------- | ----------- |
| [InstallVS.ps1](InstallVS.ps1) | Install Visual Studio 2022 from an offline vslayout with some automation. |

### How to use InstallVS.ps1
Inspired by my laziness. After a reformat (or installing a new system) I have 1.7 metric tons of software and setup to do. Visual Studio is one of those programs that is so customizable that recreating all of it (such as menus, toolbars, keyboard shortcuts, extensions, etc...) can take a very long time. If, like me, you spend 2 years changing settings, installing/removing extensions, and setting up the IDE to be just 'oh so perfect' and suddenly finding yourself in need to format this script will help automate restoring Visual Studio for you.

- Make sure you already have your vslayout folder ready. It should have all your workload files as well as a 'certificates' folder.
- Copy the script file to the root of the vslayout directory.
- By default the script will silently install the *.cer files in the 'certificates' folder.
- Next it will install Visual Studio by calling the 'VisualStudioSetup.exe' file. If your exe has a different name either rename it or rename it in the script.
- At this point you have a fresh install of Visual Studio 2022.
- If you want to install extensions first create a new folder named 'extensions' in the vslayout folder. If the script finds this folder it will ask you if you want to install them. Next download any extensions you want to install (.vsix files) from the [Visual Studio Marketplace](https://marketplace.visualstudio.com/) and place them in that folder. Each extension will be installed silently.
- If you would like to restore settings from a backup first create the backup file from the 'Tools->Import and Export Settings ...' menu in Visual Studio. Make sure the file extension is .vssettings. Place the backup file in your vslayout folder at the same level as the script. If the file exists the script will ask if you want to import the settings. They are imported by first launching Visual Studio, resetting the current settings, and then importing the backed up ones. Also not that after Visual Studio finishes importing your settings you need to close Visual studio for the script to finish.
- Please note that installing Visual Studio is a large process and as such may take several minutes to complete. Each extension can easily take a minute to install. So installing a lot of extensions can add to the time. 
