
Both elevets privileges

| sudo | run0 | doas
|---|---| --- |
| Big, mature, SUID-based. Config in /etc/sudoers. Runs sudo pacman -Syu. Lots of control, bigger target. | Systemd 256, no SUID, Polkit-driven. Runs run0 pacman -Syu. Fresh, minimal config, prompts every time. | Lean, SUID, from OpenBSD. Config in /etc/doas.conf. Runs doas pacman -Syu. Simple, less to exploit. |
| complex and powerfull | simple and secure |
| uses sudoers | uses Polkit rules |
|uses privelege binarry | uses service manager for isolation |
