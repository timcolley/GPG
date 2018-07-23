//
//  textViewWithSC.swift
//  PricegridBuilder
//
//  Created by Tim Colley on 23/08/2017.
//  Copyright © 2017 GreatRail. All rights reserved.
//

import Cocoa

/**
 Extends an NSTextfield to add copy/paste shortcut keys by default
 
 - Returns: void
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
class textViewWithSC: NSTextField {
    
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    
    /**
     Overrides the default action for an NSTextView on a keypress
     
     
     -  parameter event: **NSEvent**, a Keypress
     
     - Returns: **NSTextField.performKeyEquivalent**, The Copy/Paste keypress equivelent action
     
     */
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to:nil, from:self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}
