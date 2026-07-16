import math

def calculate_thread_length(seam_length, stitch_length, thickness):
    return (seam_length * 10 / stitch_length) * (2 * thickness + 2 * stitch_length) + 180

def main():
    seam_length = float(input("Enter seam length (cm): "))
    thickness = float(input("Enter leather thickness (mm): "))
    
    stitch_length_input = input("Enter stitch length (mm) (leave empty to calculate for 2-5mm range): ")
    
    if stitch_length_input:
        stitch_length = float(stitch_length_input)
        thread_length = calculate_thread_length(seam_length, stitch_length, thickness)
        print(f"Thread length needed: {thread_length / 10:.2f} cm")
    else:
        print("Calculating thread length for stitch lengths from 2mm to 5mm in 0.5mm steps:")
        for stitch_length in range(20, 51, 5):  # Convert to tenths of mm for accurate stepping
            thread_length = calculate_thread_length(seam_length, stitch_length / 10, thickness)
            print(f"Stitch length {stitch_length / 10:.1f} mm: {thread_length / 10:.2f} cm")

if __name__ == "__main__":
    main()
