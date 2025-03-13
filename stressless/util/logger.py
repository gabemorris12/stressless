import logging
from pathlib import Path
from stressless import LOG_PATH

# Define the log directory and file
APP_NAME = "Stressless"
# LOG_DIR = Path.home()/f".{APP_NAME.lower()}/logs"
LOG_DIR = Path(LOG_PATH)
LOG_FILE = LOG_DIR/f"{APP_NAME.lower()}.log"

# Ensure the log directory exists
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Create a logger instance
logger = logging.getLogger(APP_NAME)
logger.setLevel(logging.DEBUG)  # Set lowest logging level to capture all messages

# Remove existing handlers to prevent duplicate logs
if logger.hasHandlers():
    logger.handlers.clear()

# --- Console Handler ---
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)  # Only show DEBUG and higher in console

# Only print the message to the console (no time or level)
console_formatter = logging.Formatter('%(message)s')
console_handler.setFormatter(console_formatter)

# --- File Handler ---
file_handler = logging.FileHandler(LOG_FILE, mode='a')
file_handler.setLevel(logging.DEBUG)  # Log everything to the file

# Include timestamp and level in file log
file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)

# Add handlers to the logger
logger.addHandler(console_handler)
logger.addHandler(file_handler)

# Example log message to verify setup
logger.debug("App initialized. Logs will be written to: %s", LOG_FILE)
