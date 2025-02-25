from PIL import Image
import numpy as np

def png_to_2bit_rgb(png_filepath, output_filepath):
    """
    Converts a PNG image to a 2-bit per channel RGB representation 
    suitable for SystemVerilog demoscene use.

    Args:
        png_filepath: Path to the input PNG file.
        output_filepath: Path to the output text file containing the data.
    """

    try:
        img = Image.open(png_filepath).convert("RGB")  # Ensure RGB format
        width, height = img.size
        print(img.size)
        pixels = np.array(img)

        with open(output_filepath, "w") as f:
            f.write("\n\nreg [1:0] " + png_name +" [18:0] [32:0]; //33x19 sprite [y][x]\n\n")
            f.write("always @(*) begin\n") 
            for y in range(height):
                for x in range(width):
                    r, g, b = pixels[y, x]

                    # Quantize to 2 bits (4 levels: 0, 85, 170, 255)
                    r_2bit = (r // 85)  # Integer division gives 0-3
                    g_2bit = (g // 85)
                    b_2bit = (b // 85)

                    # Output the 2-bit values.  You can adjust the format here
                    color = f"{r_2bit:02b}{g_2bit:02b}{b_2bit:02b}"
                    if color == "001100":
                        color_2bit = 0 #background color

                    elif color == "000000":
                        color_2bit = 1 #black border color

                    elif color == "111111":
                        color_2bit = 2 #white color

                    elif color == "101010":
                        color_2bit = 3 #grey color

                    f.write(png_name + f"[{y}][{x}] = 2'b{color_2bit:02b};\n")
            f.write("end\n")


    except FileNotFoundError:
        print(f"Error: PNG file not found at {png_filepath}")
    except Exception as e:
        print(f"An error occurred: {e}")



# Example usage:
for png_name in ["sushi_run_0", "sushi_run_1"]:
    png_file = "assets/" + png_name + ".png"  # Replace with your PNG file path
    output_file = "assets/" + png_name + ".txt"  # Replace with desired output file path
    png_to_2bit_rgb(png_file, output_file)
    print(f"PNG converted to 2-bit RGB data and saved to {output_file}")
