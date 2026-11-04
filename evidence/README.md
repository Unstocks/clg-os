# PBL VISUAL EVIDENCE MANAGEMENT SYSTEM
**Project**: GMU OS 0.1 — GM University C-Oriented Learning Derivative  
**Course**: UE25CS2304 — Operating System with Practice  
**PBL Format**: Individual Student Project  
**Author**: Sanjayakumar S H, Department of CSE, GM University  

---

## 1. Purpose of this Directory
The `evidence/` directory serves as the official, tamper-proof repository for all verification artifacts generated throughout the 10-week progressive Operating Systems Project-Based Learning curriculum. 

Every completed milestone possesses concrete, verifiable proof of execution prior to progression to subsequent weeks.

---

## 2. Evidence Structure per Week
Each weekly milestone folder is organized as follows:

```text
week-XX/
├── README.md             <- Milestone summary, target files, and verification status
├── screenshots/          <- Real QEMU execution captures (.png/.jpg)
└── source_changes/       <- Exact unified diff patches against baseline (.patch)
```

- **`source_changes/`**: Store unified diffs generated via `git diff` or `diff -u`.
- **`build_logs/`**: Store text logs redirected from build commands (e.g., `make 2>&1 | tee build.log`).
- **`WEEK_XX_REPORT.md`**: Update each week with objectives, implementation details, test logs, and screenshot citations.

---

## 5. Preservation and Modification Rules
1. **Never Overwrite**: Never overwrite or delete an existing evidence file without explicit recorded justification and approval.
2. **Version Control**: Include all evidence files in milestone Git commits.
3. **Integrity**: Evidence directories must remain synchronized across Windows and Ubuntu VirtualBox environments.

