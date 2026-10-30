# Flash Andromeda OS — Raspberry Pi 4B / 4 GB / AI option 1

This is a bootable Raspberry Pi OS image, not a replacement for the Pi's
bootloader or the PocketTerm35's RP2040 keyboard firmware.

## Built image

- **Download:** [andromeda-os-pi4-4gb-ai-trixie-arm64 artifact](https://github.com/mr-f0xx/Andromeda-OS/actions/runs/40983473499/artifacts/12946407563)
- **Build run:** [Flashable image #40983473499](https://github.com/mr-f0xx/Andromeda-OS/actions/runs/40983473499) — successful
- **Firmware payload source:** `9b06e9bf2584f895865b99065d006a3112655932`
- **Artifact size:** 2,526,720,742 bytes (about 2.35 GiB)
- **Image file after extraction:** `andromeda-os-pi4-4gb-ai-trixie-arm64.img.xz`
- **SHA256:** `518c299ae9320a09c9dd471fcf0a4e3f6df1c6ec0fe91e2c0d9e63d14e72d122`
- **Artifact retention:** 14 days from the build (approximately 2026-11-13).

GitHub may require you to sign in to download Actions artifacts. The artifact
also contains `SHA256SUMS`, `BUILD-INFO.txt` and `AI-BUILD-INFO.txt`.

## Included

- Andromeda OS header and amber CRT foot terminal theme from the build revision.
- Raspberry Pi OS Trixie, 64-bit Lite, with the PocketTerm35 desktop.
- AI option 1: **MiniCPM5 2B Q4_0**, llama.cpp, llama-swap and DarkWire.
- Five DarkWire agents, configured for the account you choose on first boot.
- A **16,384-token** context and f16 KV cache, sized for **4 GB RAM**.
- The model is inside the image. No model download is needed to start chatting.

The model runs locally. DarkWire's optional web tools use the network when
invoked. A Pi 4 reads prompts more slowly than a Pi 5; the first reply after an
idle period also waits for the model to load from the SD card.

## Download and verify

1. Open the repository's **Actions → Flashable image** run for the requested
   revision. Download the artifact
   `andromeda-os-pi4-4gb-ai-trixie-arm64` and extract the ZIP.
2. In the extracted folder, check the image against `SHA256SUMS`:

   ```sh
   sha256sum -c SHA256SUMS
   ```

   On Windows:

   ```powershell
   Get-FileHash .\andromeda-os-pi4-4gb-ai-trixie-arm64.img.xz -Algorithm SHA256
   Get-Content .\SHA256SUMS
   ```

   Compare the two hashes. Do not flash a file whose checksum does not match.

## Flash

1. Use a **16 GB or larger** microSD card. Back it up first: flashing erases it.
2. In Raspberry Pi Imager, choose Raspberry Pi 4 as the device, then
   **Use custom** and select
   `andromeda-os-pi4-4gb-ai-trixie-arm64.img.xz`.
3. In OS customisation, **set a username and password**. Wi-Fi and its country
   are optional. Do not override the image's desktop/login configuration.
4. Write the card, insert it in the Pi and power on. The root filesystem expands
   on first boot. Without Imager customisation, complete the attached-screen
   first-boot account setup instead.

There is no shared default password. SSH is disabled. The desktop automatically
logs in the account you create, so physical access means access to the desktop.

## After boot

- Open **DarkWire** in the launcher. The Default agent is selected initially;
  `/agent` switches between Default, Chat, Code, Research and Lead.
- Check the AI installation in a terminal:

  ```sh
  pt35-ai status
  systemctl status pt35-ai.service --no-pager
  ```

- Flash the patched **keyboard** firmware separately, on the PocketTerm35:

  ```sh
  sudo pt35-kbd flash
  ```

  This updates the RP2040 keymap, not the Pi OS image. `sudo pt35-kbd restore`
  reverses it. Do not interrupt keyboard flashing.

The correct PocketTerm35 touch overlay is `waveshare-35dpi-5b.dtbo` on both Pi 4B
and Pi 5: the unit's Goodix controller uses the address in that overlay. The
image also enables the USB host connection required by the keyboard.

## Build provenance and limits

The artifact includes `BUILD-INFO.txt` (source revision and build URL),
`AI-BUILD-INFO.txt` (model/runtime versions and model checksum), and
`SHA256SUMS`. The workflow checks the model checksum, ARM64 binaries, boot files,
enabled services, locked initial account and 4 GB context configuration. It also
decompression-tests the image. These checks are not a substitute for a hardware
boot test on your own PocketTerm35. Live OS packages and the developing DarkWire
client mean builds are not bit-for-bit reproducible; the manifest records what
was included.
