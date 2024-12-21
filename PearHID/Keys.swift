//
//  Keys.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//
import Foundation

// Struct for a key group and its keys
struct KeyGroup: Identifiable {
    let id = UUID()
    let group: String
    let keys: [KeyItem]
}

struct KeyItem: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let hex: UInt64
}

struct KeyMapping: Identifiable {
    let id = UUID()
    var from: KeyItem?
    var to: KeyItem?
}

let allKeys: [KeyGroup] = [
    KeyGroup(group: "Modifier keys", keys: [
        KeyItem(key: "caps_lock", hex: 0x39),
        KeyItem(key: "left_control", hex: 0xE0),
        KeyItem(key: "left_shift", hex: 0xE1),
        KeyItem(key: "left_option", hex: 0xE2),
        KeyItem(key: "left_command", hex: 0xE3),
        KeyItem(key: "right_control", hex: 0xE4),
        KeyItem(key: "right_shift", hex: 0xE5),
        KeyItem(key: "right_option", hex: 0xE6),
        KeyItem(key: "right_command", hex: 0xE7),
        KeyItem(key: "fn", hex: 0x0003 + 0xFF00000000 - 0x700000000)
    ]),
    KeyGroup(group: "Controls and symbols", keys: [
        KeyItem(key: "return_or_enter", hex: 0x28),
        KeyItem(key: "escape", hex: 0x29),
        KeyItem(key: "delete_or_backspace", hex: 0x2A),
        KeyItem(key: "delete_forward", hex: 0x4C),
        KeyItem(key: "tab", hex: 0x2B),
        KeyItem(key: "spacebar", hex: 0x2C),
        KeyItem(key: "hyphen (-)", hex: 0x2D),
        KeyItem(key: "equal_sign (=)", hex: 0x2E),
        KeyItem(key: "open_bracket [", hex: 0x2F),
        KeyItem(key: "close_bracket ]", hex: 0x30),
        KeyItem(key: "backslash (\\)", hex: 0x31),
        KeyItem(key: "non_us_pound", hex: 0x32),
        KeyItem(key: "semicolon (;)", hex: 0x33),
        KeyItem(key: "quote (')", hex: 0x34),
        KeyItem(key: "grave_accent_and_tilde (`)", hex: 0x35),
        KeyItem(key: "comma (,)", hex: 0x36),
        KeyItem(key: "period (.)", hex: 0x37),
        KeyItem(key: "slash (/)", hex: 0x38),
        KeyItem(key: "non_us_backslash (\\), section (§)", hex: 0x64)
    ]),
    KeyGroup(group: "Arrow keys", keys: [
        KeyItem(key: "up_arrow", hex: 0x52),
        KeyItem(key: "down_arrow", hex: 0x51),
        KeyItem(key: "left_arrow", hex: 0x50),
        KeyItem(key: "right_arrow", hex: 0x4F),
        KeyItem(key: "page_up", hex: 0x4B),
        KeyItem(key: "page_down", hex: 0x4E),
        KeyItem(key: "home", hex: 0x4A),
        KeyItem(key: "end", hex: 0x4D)
    ]),
    KeyGroup(group: "Letter keys", keys: [
        KeyItem(key: "a", hex: 0x04),
        KeyItem(key: "b", hex: 0x05),
        KeyItem(key: "c", hex: 0x06),
        KeyItem(key: "d", hex: 0x07),
        KeyItem(key: "e", hex: 0x08),
        KeyItem(key: "f", hex: 0x09),
        KeyItem(key: "g", hex: 0x0A),
        KeyItem(key: "h", hex: 0x0B),
        KeyItem(key: "i", hex: 0x0C),
        KeyItem(key: "j", hex: 0x0D),
        KeyItem(key: "k", hex: 0x0E),
        KeyItem(key: "l", hex: 0x0F),
        KeyItem(key: "m", hex: 0x10),
        KeyItem(key: "n", hex: 0x11),
        KeyItem(key: "o", hex: 0x12),
        KeyItem(key: "p", hex: 0x13),
        KeyItem(key: "q", hex: 0x14),
        KeyItem(key: "r", hex: 0x15),
        KeyItem(key: "s", hex: 0x16),
        KeyItem(key: "t", hex: 0x17),
        KeyItem(key: "u", hex: 0x18),
        KeyItem(key: "v", hex: 0x19),
        KeyItem(key: "w", hex: 0x1A),
        KeyItem(key: "x", hex: 0x1B),
        KeyItem(key: "y", hex: 0x1C),
        KeyItem(key: "z", hex: 0x1D)
    ]),
    KeyGroup(group: "Number keys", keys: [
        KeyItem(key: "1", hex: 0x1E),
        KeyItem(key: "2", hex: 0x1F),
        KeyItem(key: "3", hex: 0x20),
        KeyItem(key: "4", hex: 0x21),
        KeyItem(key: "5", hex: 0x22),
        KeyItem(key: "6", hex: 0x23),
        KeyItem(key: "7", hex: 0x24),
        KeyItem(key: "8", hex: 0x25),
        KeyItem(key: "9", hex: 0x26),
        KeyItem(key: "0", hex: 0x27)
    ]),
    KeyGroup(group: "Function keys", keys: [
        KeyItem(key: "f1", hex: 0x3A),
        KeyItem(key: "f2", hex: 0x3B),
        KeyItem(key: "f3", hex: 0x3C),
        KeyItem(key: "f4", hex: 0x3D),
        KeyItem(key: "f5", hex: 0x3E),
        KeyItem(key: "f6", hex: 0x3F),
        KeyItem(key: "f7", hex: 0x40),
        KeyItem(key: "f8", hex: 0x41),
        KeyItem(key: "f9", hex: 0x42),
        KeyItem(key: "f10", hex: 0x43),
        KeyItem(key: "f11", hex: 0x44),
        KeyItem(key: "f12", hex: 0x45),
        KeyItem(key: "f13", hex: 0x68),
        KeyItem(key: "f14", hex: 0x69),
        KeyItem(key: "f15", hex: 0x6A),
        KeyItem(key: "f16", hex: 0x6B),
        KeyItem(key: "f17", hex: 0x6C),
        KeyItem(key: "f18", hex: 0x6D),
        KeyItem(key: "f19", hex: 0x6E)
    ]),
    KeyGroup(group: "Media control keys", keys: [
        KeyItem(key: "display_brightness_decrement", hex: UInt64(0xC00000070) - UInt64(0x700000000)),
        KeyItem(key: "display_brightness_increment", hex: UInt64(0xC0000006F) - UInt64(0x700000000)),
        KeyItem(key: "rewind", hex: UInt64(0xC000000B4) - UInt64(0x700000000)),
        KeyItem(key: "play_or_pause", hex: UInt64(0xC000000CD) - UInt64(0x700000000)),
        KeyItem(key: "fast_forward", hex: UInt64(0xC000000B3) - UInt64(0x700000000)),
        KeyItem(key: "mute", hex: UInt64(0xC000000E2) - UInt64(0x700000000)),
        KeyItem(key: "volume_decrement", hex: UInt64(0xC000000EA) - UInt64(0x700000000)),
        KeyItem(key: "volume_increment", hex: UInt64(0xC000000E9) - UInt64(0x700000000))
    ]),
    KeyGroup(group: "Keys in pc keyboards", keys: [
        KeyItem(key: "print_screen", hex: 0x46),
        KeyItem(key: "scroll_lock", hex: 0x47),
        KeyItem(key: "pause", hex: 0x48),
        KeyItem(key: "insert", hex: 0x49),
        KeyItem(key: "application", hex: 0x65),
        KeyItem(key: "help", hex: 0x75),
        KeyItem(key: "power", hex: 0x66),
        KeyItem(key: "execute", hex: 0x74),
        KeyItem(key: "menu", hex: 0x76),
        KeyItem(key: "select", hex: 0x77),
        KeyItem(key: "stop", hex: 0x78),
        KeyItem(key: "again", hex: 0x79),
        KeyItem(key: "undo", hex: 0x7A),
        KeyItem(key: "cut", hex: 0x7B),
        KeyItem(key: "copy", hex: 0x7C),
        KeyItem(key: "paste", hex: 0x7D),
        KeyItem(key: "find", hex: 0x7E),
        KeyItem(key: "mute", hex: 0x7F),
        KeyItem(key: "volume_up", hex: 0x80),
        KeyItem(key: "volume_down", hex: 0x81),
        KeyItem(key: "locking_caps_lock", hex: 0x82),
        KeyItem(key: "locking_num_lock", hex: 0x83),
        KeyItem(key: "locking_scroll_lock", hex: 0x84)
    ]),
    KeyGroup(group: "Keypad keys", keys: [
        KeyItem(key: "keypad_num_lock", hex: 0x53),
        KeyItem(key: "keypad_slash (/)", hex: 0x54),
        KeyItem(key: "keypad_asterisk (*)", hex: 0x55),
        KeyItem(key: "keypad_hyphen (-)", hex: 0x56),
        KeyItem(key: "keypad_plus (+)", hex: 0x57),
        KeyItem(key: "keypad_enter", hex: 0x58),
        KeyItem(key: "keypad_1", hex: 0x59),
        KeyItem(key: "keypad_2", hex: 0x5A),
        KeyItem(key: "keypad_3", hex: 0x5B),
        KeyItem(key: "keypad_4", hex: 0x5C),
        KeyItem(key: "keypad_5", hex: 0x5D),
        KeyItem(key: "keypad_6", hex: 0x5E),
        KeyItem(key: "keypad_7", hex: 0x5F),
        KeyItem(key: "keypad_8", hex: 0x60),
        KeyItem(key: "keypad_9", hex: 0x61),
        KeyItem(key: "keypad_0", hex: 0x62),
        KeyItem(key: "keypad_period (.)", hex: 0x63),
        KeyItem(key: "keypad_equal_sign (=)", hex: 0x67),
        KeyItem(key: "keypad_comma (,)", hex: 0x85)
    ])
]
