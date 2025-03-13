import logging

APP_NAME = 'Stressless'

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

# Add handlers to the logger
logger.addHandler(console_handler)
