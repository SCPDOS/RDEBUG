;ROM Debugger activator.
;Tests if address of Int 38h is not equal to Int 39h
;If it is not, it scans the 64Kb block after the ROMBIOS for the string SCPBIOS
;If it finds it, it triggers Int 38h to enter the debugger
[map all ./Listings/rdebug.map]
[DEFAULT REL]
BITS 64
    mov eax, 3538h  ;Get the ptr for interrupt 38h in rbx
    int 21h
    mov rdi, rbx
    mov eax, 3539h
    int 21h
    cmp rdi, rbx
    je .badExit
    ;Now we scan 64Kb from rdi
    mov al, "S"
    mov ecx, 10000h
.keepSearching:
    repne scasb
    je .potential
.badExit:
    lea rdx, badMsg
    mov eax, 0900h
    int 21h
    mov eax, 4CFFh
    int 21h
.potential:
    push rax
    push rdi
    dec rdi
    mov rax, "SYSDEBUG"
    cmp qword [rdi], rax
    pop rdi
    pop rax
    jne .keepSearching
    ; If found, save the original Int 40h handler
    mov eax, 3540h  ;Get the original handles
    int 21h
    mov qword [hdlr], rbx
    lea rdx, intHdlr
    mov eax, 2540h
    int 21h
    int 38h ;Call the debugger, hooking our return point
intHdlr:
    mov rdx, qword [hdlr]
    mov eax, 2540h
    int 21h
    int 20h

badMsg:  db "SCP/BIOS Debugger Not Detected",0Dh,0Ah,"$"
hdlr dq 0   ; Original interrupt handler here