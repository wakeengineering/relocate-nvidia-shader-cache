# relocate-nvidia-shader-cache

This is a simple script to relocate the NVIDIA shader cache. It requires manual steps to disable the shader cache, configure the new location using a `.conf` file, and then re-enable the shader cache in the NVIDIA Control Panel.

## Usage

1. Disable the shader cache in the NVIDIA Control Panel.
2. Edit the configuration file (e.g., `relocate-nvidia-shader-cache.conf`) to set the intended new location for the shader cache/s.
3. Run the wrapper script located in this repo `relocate-nvidia-shader-cache-wrapper.cmd`. (May need to restart for OS folder locks on existing cache folders to release)
4. Re-enable the shader cache at desired amount in the NVIDIA Control Panel.

## Note

Ensure that you have administrative privileges and follow the steps carefully to avoid any data loss or corruption.

## Script

The script is written in PowerShell and can be found at `relocate-nvidia-shader-cache.ps1`. It checks if the shader cache directories already exist as junctions and removes them if necessary, then creates new junctions to the specified locations.

## Configuration File

The configuration file `relocate-nvidia-shader-cache.conf` should contain the following lines:

```
DXCACHE=E:\_new_shader_cache_location\DXCache
GLCACHE=E:\_new_shader_cache_location\GLCache
```

Replace `E:\_new_shader_cache_location` with your desired new location for the shader cache.

## Contributing

If you have any improvements or bug fixes, feel free to contribute by creating a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.