from PyQt6.QtCore import QSettings

SETTINGS = QSettings("StandardMechanics", "Stressless")

# Clear the settings for testing purposes (comment out to keep settings)
# SETTINGS.clear()
# SETTINGS.sync()
