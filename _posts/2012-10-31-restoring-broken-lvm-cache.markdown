---
layout: post
title: Restoring a broken LVM cache
---

0. A working LVM setup - e.g. `lvdisplay` shows something
1. `/sbin/dmsetup remove_all` (or similar)
2. `lvdisplay` (or any) will now say "No volume groups found"
3. Similarly, `pvdisplay` won't even find your drives

You can get this back with `lvm pvscan`, `lvm vgscan` and `lvm lvscan`
(for whatever you broke).
