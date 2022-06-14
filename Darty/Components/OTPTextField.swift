//
//  OTPTextField.swift
//  Darty
//
//  Created by Руслан Садыков on 11.06.2022.
//

import UIKit

final class OTPTextField: BottomLineTextField {

    // MARK: - Properties
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?

    override public func deleteBackward() {
        text = ""
        previousTextField?.becomeFirstResponder()
    }
}


protocol OTPDelegate: AnyObject {
    //always triggers when the OTP field is valid
    func didChangeValidity(isValid: Bool)
}

class OTPStackView: UIStackView {

    //Customise the OTPField here
    var textFieldsCollection: [OTPTextField] = []
    weak var delegate: OTPDelegate?
    var showsWarningColor = false

    //Colors
    private var remainingStrStack: [String] = []

    private let codeLength: Int

    init(codeLength: Int) {
        self.codeLength = codeLength
        super.init(frame: .zero)
        setupStackView()
        addOTPFields()
    }

    required init(coder: NSCoder) {
        self.codeLength = 6
        super.init(coder: coder)
    }

    //Customisation and setting stackView
    private final func setupStackView() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 5
    }

    //Adding each OTPfield to stack view
    private final func addOTPFields() {
        for index in 0..<codeLength {
            let field = OTPTextField(color: .systemPurple)
            setupTextField(field)
            textFieldsCollection.append(field)
            //Adding a marker to previous field
            index != 0 ? (field.previousTextField = textFieldsCollection[index-1]) : (field.previousTextField = nil)
            //Adding a marker to next field for the field at index-1
            index != 0 ? (textFieldsCollection[index-1].nextTextField = field) : ()
        }
        textFieldsCollection[0].becomeFirstResponder()
    }

    //Customisation and setting OTPTextFields
    private final func setupTextField(_ textField: OTPTextField) {
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addArrangedSubview(textField)
        textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 40).isActive = true
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = false
        textField.font = .sfProText(ofSize: 25, weight: .medium)
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .yes
        textField.textContentType = .oneTimeCode
//        textField.tintColor = .clear
    }

    //checks if all the OTPfields are filled
    private final func checkForValidity() {
        for fields in textFieldsCollection {
            if (fields.text == "") {
                delegate?.didChangeValidity(isValid: false)
                return
            }
        }
        delegate?.didChangeValidity(isValid: true)
    }

    //gives the OTP text
    final func getOTP() -> String {
        var OTP = ""
        for textField in textFieldsCollection{
            OTP += textField.text ?? ""
        }
        return OTP
    }

    //set isWarningColor true for using it as a warning color
    final func setAllFieldColor(isWarningColor: Bool = false, color: UIColor){
        for textField in textFieldsCollection {
            #warning("Почему-то сука не работает")
            textField.setErrorBottomColor()
        }
        showsWarningColor = isWarningColor
    }

    //autofill textfield starting from first
    private final func autoFillTextField(with string: String) {
        remainingStrStack = string.reversed().compactMap{String($0)}
        for textField in textFieldsCollection {
            if let charToAdd = remainingStrStack.popLast() {
                textField.text = String(charToAdd)
            } else {
                break
            }
        }
        checkForValidity()
        remainingStrStack = []
    }

}

//MARK: - TextField Handling
extension OTPStackView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if showsWarningColor {
            setAllFieldColor(isWarningColor: true, color: .systemRed)
            showsWarningColor = false
        }
        (textField as? OTPTextField)?.select(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForValidity()
//        textField.layer.borderColor = inactiveFieldBorderColor.cgColor
        (textField as? OTPTextField)?.select(!(textField.text?.isEmpty ?? true))
    }

    //switches between OTPTextfields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange,
                   replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else { return true }
        if string.count > 1 {
            textField.resignFirstResponder()
            autoFillTextField(with: string)
            return false
        } else {
            if (range.length == 0) {
                if textField.nextTextField == nil {
                    textField.text? = string
                    textField.resignFirstResponder()
                }else{
                    textField.text? = string
                    textField.nextTextField?.becomeFirstResponder()
                }
                return false
            }
            return true
        }
    }
}