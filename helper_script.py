from pynput import mouse, keyboard
from PIL import ImageGrab
import sys

# Flag to control the script's running state
running = True

def rgb_to_hex(rgb):
    """Convert an RGB tuple to a hex color string"""
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2]).upper()

def on_click(x, y, button, pressed):
    """Mouse click listener"""
    if button == mouse.Button.right and pressed:
        try:
            screenshot = ImageGrab.grab(all_screens=True)
            # Get the pixel color at (x, y)
            rgb = screenshot.getpixel((x, y))
            hex_color = rgb_to_hex(rgb)
            print(f"Right mouse button pressed at X: {x}, Y: {y}, RGB: {rgb}, HEX: {hex_color}")
        except IndexError:
            print(f"Right mouse button pressed at X: {x}, Y: {y}, but coordinates are outside the screen bounds.")

def on_press(key):
    """Key press listener"""
    global running
    if key == keyboard.Key.space:
        print("Spacebar pressed. Exiting...")
        running = False
        return False

# Set up the mouse listener
mouse_listener = mouse.Listener(on_click=on_click)
mouse_listener.start()

# Set up the keyboard listener
keyboard_listener = keyboard.Listener(on_press=on_press)
keyboard_listener.start()

# Keep the script running until the spacebar is pressed
while running:
    pass

# Stop the listeners
mouse_listener.stop()
keyboard_listener.stop()