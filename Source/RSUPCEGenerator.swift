//
//  RSUPCEGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.sly.com.tw/skill/know/new_page_6.htm
// http://mdn.morovia.com/kb/UPCE-Specification-10634.html
// http://mdn.morovia.com/kb/UPCA-Specification-10632.html
// http://www.barcodeisland.com/upce.phtml
open class RSUPCEGenerator: RSAbstractCodeGenerator, RSCheckDigitGenerator {
    let UPCE_ODD_ENCODINGS = [
        "0001101",
        "0011001",
        "0010011",
        "0111101",
        "0100011",
        "0110001",
        "0101111",
        "0111011",
        "0110111",
        "0001011"
    ]
    
    let UPCE_EVEN_ENCODINGS = [
        "0100111",
        "0110011",
        "0011011",
        "0100001",
        "0011101",
        "0111001",
        "0000101",
        "0010001",
        "0001001",
        "0010111"
    ]
    
    let UPCE_SEQUENCES = [
        "000111",
        "001011",
        "001101",
        "001110",
        "010011",
        "011001",
        "011100",
        "010101",
        "010110",
        "011010"
    ]
    
    func convert2UPC_A(_ contents:String) -> String {
        var upc_a = ""
        if let code = contents.rs.substring(1, length: contents.rs.length() - 2) {
            let lastDigit = Int(code.rs[code.rs.length() - 1])!
            var insertDigits = "0000"
            switch lastDigit {
            case 0...2:
                upc_a += code.rs.substring(0, length: 2) + String(lastDigit) + insertDigits + code.rs.substring(2, length: 3)
            case 3:
            insertDigits = "00000"
            upc_a += code.rs.substring(0, length: 3) + insertDigits + code.rs.substring(3, length: 2)
            case 4:
            insertDigits = "00000"
            upc_a += code.rs.substring(0, length: 4) + insertDigits + code.rs.substring(4, length: 1)
            default:
                upc_a += code.rs.substring(0, length: 5) + insertDigits + String(lastDigit)
            }
        }
        return "00" + upc_a
    }
    
    override open func isValid(_ contents: String) -> Bool {
        return super.isValid(contents)
            && contents.rs.length() == 8
            && Int(contents.rs[0])! == 0
            && contents.rs[contents.rs.length() - 1] == self.checkDigit(contents)
    }
    
    override open func initiator() -> String {
        return "101"
    }
    
    override open func terminator() -> String {
        return "010101"
    }
    
    override open func barcode(_ contents: String) -> String {
        let checkValue = Int(contents.rs[contents.rs.length() - 1])!
        let sequence = UPCE_SEQUENCES[checkValue]
        var barcode = ""
        for i in 1..<contents.rs.length() - 1 {
            let digit = Int(contents.rs[i])!
            if Int(sequence.rs[i - 1])! % 2 == 0 {
                barcode += UPCE_EVEN_ENCODINGS[digit]
            } else {
                barcode += UPCE_ODD_ENCODINGS[digit]
            }
        }
        return barcode
    }
    
    // MARK: RSCheckDigitGenerator
    
    open func checkDigit(_ contents: String) -> String {
        /*
         UPC-A check digit is calculated using standard Mod10 method. Here outlines the steps to calculate UPC-A check digit:
         
         From the right to left, start with odd position, assign the odd/even position to each digit.
         Sum all digits in odd position and multiply the result by 3.
         Sum all digits in even position.
         Sum the results of step 3 and step 4.
         divide the result of step 4 by 10. The check digit is the number which adds the remainder to 10.
         If there is no remainder then the check digit equals zero.
         */
        let upc_a = self.convert2UPC_A(contents)
        var sum_odd = 0
        var sum_even = 0
        for i in 0..<upc_a.rs.length() {
            let digit = Int(upc_a.rs[i])!
            if i % 2 == 0 {
                sum_even += digit
            } else {
                sum_odd += digit
            }
        }
        let remainder = (sum_even + sum_odd * 3) % 10
        return String(remainder == 0 ? remainder : 10 - remainder)
    }
}
