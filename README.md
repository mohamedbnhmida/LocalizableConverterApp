
# 🛠 SwiftUI Localization Tool for macOS

A powerful macOS tool built with SwiftUI that enables developers to search across compiled localized strings in the Pods folder of their project. This tool also converts the compiled `.strings` files back into human-readable, localizable files—complete with emojis for better readability and fun!

---

## 🚀 Features

- **Search Functionality:** Quickly search through compiled localized strings across the `Pods` folder.  
- **Conversion to Human-Readable Format:** Decode compiled `.strings` files into readable `.strings` or `.csv` format.  
- **Emoji Support:** Add emojis to make localization files visually appealing and easier to read.  
- **SwiftUI Interface:** A sleek and modern interface designed for ease of use.  
- **Batch Processing:** Process multiple files or directories at once for maximum productivity.  
- **Cross-Pod Support:** Easily handle localization files from various dependencies in the `Pods` folder.

---

## 🛠 Requirements

- **macOS:** 12.0 (Monterey) or later  
- **Xcode:** 13.0 or later  
- **Swift:** 5.5 or later  

---

## 💻 Installation

1. Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/localization-tool.git
   cd localization-tool
   ```

2. Open the project in Xcode:  
   ```bash
   open LocalizationTool.xcodeproj
   ```

3. Build and run the project on your macOS system.

---

## 🔍 How to Use

### **1. Search Localized Strings**  
- Select the `Pods` folder or any directory containing compiled `.strings` files.  
- Use the search bar to find specific strings or keys.

### **2. Convert Strings Files**  
- Click on the "Convert" button to decode the compiled `.strings` files into human-readable format.  
- Choose the desired output format (`.strings`, `.csv`, etc.).  

### **3. Emojis in Localized Files**  
- Enable the "Include Emojis" option to automatically add relevant emojis to your localized strings for better readability.  

---

## 🤩 Sample Output

### **Input:**  
```plaintext
/* Class = "UIButton"; normalTitle = "OK"; ObjectID = "123"; */
"123.normalTitle" = "OK";
```

### **Output with Emojis:**  
```plaintext
/* Button ➡️ Confirm Action */
"OK ✅" = "OK";
```

---

## 🎨 UI Preview

- A clean and intuitive SwiftUI interface with real-time previews of decoded files.  
- Progress indicators for batch processes.  

---

## 🧑‍💻 Contributing

Contributions are welcome! To contribute:  

1. Fork the repository.  
2. Create a new branch (`feature/new-feature`).  
3. Commit your changes (`git commit -m 'Add a new feature'`).  
4. Push to the branch (`git push origin feature/new-feature`).  
5. Create a Pull Request.  

---

## 🛡 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🌟 Acknowledgements

- Inspired by the need to simplify localization workflows.  
- Developed with ❤️ using SwiftUI.  

---

Feel free to contact me at `youremail@example.com` if you have any questions or suggestions!
