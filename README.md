# **Windows Optimizer**

The **Windows Optimizer** script is a powerful tool to enhance your system’s performance. It cleans up temporary files, clears browser caches, removes unnecessary logs, and terminates resource-hogging processes. It’s designed to improve system speed and free up valuable disk space.

## 🚀 **Features**

- **Close Unnecessary Processes**  
  Terminates background processes like browsers, update services, and other unnecessary applications to boost system performance.
  
- **Remove Temporary Files**  
  Deletes user and system temporary files to free up disk space.

- **Clear Browser Caches**  
  Removes cache for popular browsers like **Microsoft Edge**, **Mozilla Firefox**, and **Google Chrome**, improving browser performance and freeing up storage.

- **Remove Unnecessary Logs**  
  Deletes system logs and error reports to clean up your system.

- **Generates Log File**  
  Tracks the actions performed by the script and saves them in a log file on your desktop for easy reference.

## 🛠 **Requirements**

- **Operating System**: Windows
- **Administrator Privileges**: The script requires elevated privileges to perform system-level tasks.

## ⚙️ **Installation**

1. **Download** or **Clone** this repository to your computer.
2. Save the script file (`windows_optimizer.bat`) in a location of your choice.
3. Right-click on the script file and select **Run as Administrator**.

## 📝 **Usage**

1. **Run the Script**  
   Right-click the `.bat` file and select **Run as Administrator** to start the optimization process.

2. The script will automatically:
   - Close unnecessary processes.
   - Remove temporary files.
   - Clear browser caches.
   - Delete unnecessary logs.

3. **Log File Generation**  
   Once the script finishes, a log file will be generated on your **Desktop** with detailed information about the performed actions. The log file is named with the format:
   - `windows_optimizer_log_<date>_<time>.txt`

## 📂 **Log File Location**

The log file will be saved on your **Desktop** with the naming format:

Example:  
`windows_optimizer_log_2025-02-23_15-30.txt`

## 🔄 **Processes Closed**

The script will attempt to close the following processes to optimize system performance:

- `ccleaner64.exe`  
- `ccleaner.exe`  
- `msedge.exe` (Microsoft Edge)  
- `firefox.exe` (Mozilla Firefox)  
- `vivaldi.exe` (Vivaldi Browser)  
- `brave.exe` (Brave Browser)  
- `chrome.exe` (Google Chrome)  
- `Acrotray.exe` (Adobe Acrobat Update Service)  
- `GoogleUpdate.exe` (Google Update)  
- `Skype.exe`  
- `Spotify.exe`  
- `Steam.exe`  
- `Cortana.exe`

> **Note**: The script will not close essential system processes, only those deemed unnecessary for optimization.

## ⚠️ **Important Notes**

- **Administrator Privileges Required**: Make sure to run the script as **Administrator** to allow all required actions to be executed.
- The script is designed to close only unnecessary processes, leaving essential system processes untouched.
- A **log file** will be generated, providing detailed information about each step and process that was handled.

## 📝 **License**

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

## 🤝 **Contributions**

Contributions are welcome! Feel free to:
- Open issues for feedback or bug reports.
- Submit **pull requests** to add new features or improvements.

## 📧 **Contact**

For any questions or support, feel free to reach out:

- **Email**: victorvernier@proton.me  
- **GitHub**: [@victorvernier](https://github.com/victorvernier)
