.MODEL SMALL
.STACK 100H

.DATA
    ; Login Variables
    PASSWORD        DB 'admin', 0       ; Hardcoded password (null terminated)
    INPUT_BUFFER    DB 20 DUP(0)        ; Buffer for user input
    LOGIN_ATTEMPTS  DB 0
    MAX_ATTEMPTS    DB 3
    
    ; Candidate Variables
    ; We will store up to 5 candidates, each name max 20 chars
    ; 5 * 20 = 100 bytes
    ; Initialized to 0 (empty)
    CANDIDATES      DB 100 DUP(0)   
    CAND_COUNT      DB 0
    MAX_CANDIDATES  DB 5
    CAND_NAME_LEN   DB 20           ; Max length per name

    ; Messages
    MSG_ENTER_PASS  DB 0Dh, 0Ah, 'Enter Password: $'
    MSG_WELCOME     DB 0Dh, 0Ah, 'Login Successful! Welcome Admin.', 0Dh, 0Ah, '$'
    MSG_WRONG_PASS  DB 0Dh, 0Ah, 'Invalid Password!', 0Dh, 0Ah, '$'
    MSG_LOCKED      DB 0Dh, 0Ah, 'SYSTEM LOCKED due to too many failed attempts.', 0Dh, 0Ah, '$'
    
    MSG_MENU        DB 0Dh, 0Ah, 0Dh, 0Ah, '--- MAIN MENU ---', 0Dh, 0Ah
                    DB '1. Add Candidate', 0Dh, 0Ah
                    DB '2. View Candidates', 0Dh, 0Ah
                    DB '3. Search Candidate', 0Dh, 0Ah
                    DB '4. Remove Candidate', 0Dh, 0Ah
                    DB '5. Exit', 0Dh, 0Ah
                    DB 'Select option: $'
                    
    MSG_ADD_NAME    DB 0Dh, 0Ah, 'Enter Candidate Name: $'
    MSG_FULL        DB 0Dh, 0Ah, 'Error: List is full!', 0Dh, 0Ah, '$'
    MSG_ADDED       DB 0Dh, 0Ah, 'Candidate Added.', 0Dh, 0Ah, '$'
    
    MSG_SEARCH_PRPT DB 0Dh, 0Ah, 'Enter Name to Search: $'
    MSG_FOUND       DB 0Dh, 0Ah, 'Candidate Found!', 0Dh, 0Ah, '$'
    MSG_NOT_FOUND   DB 0Dh, 0Ah, 'Candidate Not Found.', 0Dh, 0Ah, '$'
    
    MSG_DEL_PRPT    DB 0Dh, 0Ah, 'Enter Name to Remove: $'
    MSG_DELETED     DB 0Dh, 0Ah, 'Candidate Removed.', 0Dh, 0Ah, '$'
    
    MSG_EMPTY_LIST  DB 0Dh, 0Ah, 'No candidates in the list.', 0Dh, 0Ah, '$'
    
    NEWLINE         DB 0Dh, 0Ah, '$'

.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX          ; Set ES for string operations (required for some instructions)

    ; --- FEATURE 1: LOGIN SYSTEM ---
LOGIN_LOOP:
    ; Check attempts
    MOV AL, LOGIN_ATTEMPTS
    CMP AL, MAX_ATTEMPTS
    JAE SYSTEM_LOCK     ; If attempts >= max, lock system

    ; Prompt Password
    LEA DX, MSG_ENTER_PASS
    MOV AH, 09h
    INT 21h

    ; Read Password
    CALL READ_STRING    ; Reads into INPUT_BUFFER

    ; Verify Password
    ; Compare INPUT_BUFFER with PASSWORD
    LEA SI, INPUT_BUFFER
    LEA DI, PASSWORD
    
    CALL COMPARE_STRINGS
    CMP AX, 1           ; AX=1 if match, 0 if mismatch
    JE LOGIN_SUCCESS

    ; Failed Login
    LEA DX, MSG_WRONG_PASS
    MOV AH, 09h
    INT 21h
    
    INC LOGIN_ATTEMPTS
    JMP LOGIN_LOOP

SYSTEM_LOCK:
    LEA DX, MSG_LOCKED
    MOV AH, 09h
    INT 21h
    JMP EXIT_PROGRAM    ; Terminate program

LOGIN_SUCCESS:
    LEA DX, MSG_WELCOME
    MOV AH, 09h
    INT 21h


    ; --- MAIN MENU LOOP ---
MAIN_MENU:
    LEA DX, MSG_MENU
    MOV AH, 09h
    INT 21h
    
    ; Read single char for option
    MOV AH, 01h
    INT 21h
    MOV BL, AL          ; Save option in BL
    
    ; Handle Options
    CMP BL, '1'
    JE OPT_ADD
    CMP BL, '2'
    JE OPT_VIEW
    CMP BL, '3'
    JE OPT_SEARCH
    CMP BL, '4'
    JE OPT_REMOVE
    CMP BL, '5'
    JE EXIT_PROGRAM
    
    JMP MAIN_MENU       ; Invalid input, loop back

    ; --- OPTION HANDLERS ---
OPT_ADD:
    CALL ADD_CANDIDATE
    JMP MAIN_MENU

OPT_VIEW:
    CALL VIEW_CANDIDATES
    JMP MAIN_MENU

OPT_SEARCH:
    CALL SEARCH_CANDIDATE
    JMP MAIN_MENU

OPT_REMOVE:
    CALL REMOVE_CANDIDATE
    JMP MAIN_MENU

EXIT_PROGRAM:
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; -----------------------------------------------------
; PROCEDURES
; -----------------------------------------------------

; procedure: READ_STRING
; Description: Reads string from user into INPUT_BUFFER until Enter key.
;              Null-terminates the string.
READ_STRING PROC
    PUSH AX
    PUSH BX
    PUSH SI
    
    LEA SI, INPUT_BUFFER
    
READ_CHAR_LOOP:
    MOV AH, 01h
    INT 21h
    
    CMP AL, 0Dh         ; Check for Enter key
    JE END_READ
    
    MOV [SI], AL        ; Store char
    INC SI
    JMP READ_CHAR_LOOP
    
END_READ:
    MOV [SI], 0         ; Null terminate
    POP SI
    POP BX
    POP AX
    RET
READ_STRING ENDP


; procedure: COMPARE_STRINGS
; Description: Compares null-terminated strings at SI and DI.
; Output: AX = 1 if match, 0 if mismatch.
COMPARE_STRINGS PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX

CMP_LOOP:
    MOV BL, [SI]
    MOV BH, [DI]
    
    CMP BL, BH
    JNE CMP_MISMATCH
    
    CMP BL, 0           ; Check if end of string (and they are equal)
    JE CMP_MATCH
    
    INC SI
    INC DI
    JMP CMP_LOOP

CMP_MISMATCH:
    MOV AX, 0
    JMP CMP_EXIT

CMP_MATCH:
    MOV AX, 1

CMP_EXIT:
    POP BX
    POP CX
    POP DI
    POP SI
    RET
COMPARE_STRINGS ENDP


; --- FEATURE 2 PROCEDURES ---

ADD_CANDIDATE PROC
    ; Check if full
    MOV AL, CAND_COUNT
    CMP AL, MAX_CANDIDATES
    JAE LIST_FULL_ERR
    
    ; Prompt Name
    LEA DX, MSG_ADD_NAME
    MOV AH, 09h
    INT 21h
    
    ; Find first empty slot
    ; We iterate through CANDIDATES list. An empty slot usually starts with 0.
    ; However, simplified logical mapping: Slot index = specific memory offset.
    ; We need to find *where* to write.
    
    ; Just use a simple search for first byte 0 in steps of 20
    LEA DI, CANDIDATES
    MOV CX, 5           ; Max 5 candidates
    MOV DX, 20          ; Stride length
    
FIND_EMPTY_SLOT:
    CMP BYTE PTR [DI], 0    ; Check if first byte is 0 (empty)
    JE READ_INTO_SLOT
    ADD DI, 20          ; Move to next slot
    LOOP FIND_EMPTY_SLOT
    
    ; Should not reach here if count check passed, but safety:
    JMP LIST_FULL_ERR 

READ_INTO_SLOT:
    ; DI points to the start of the empty slot
    ; We'll reuse logic similar to READ_STRING but write directly to [DI]
    
    PUSH DI
    ; Read string loop directly into memory pointed by DI
READ_CAND_LOOP:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE FINISH_ADD
    MOV [DI], AL
    INC DI
    JMP READ_CAND_LOOP
    
FINISH_ADD:
    MOV BYTE PTR [DI], 0   ; Null terminate
    POP DI
    
    INC CAND_COUNT
    LEA DX, MSG_ADDED
    MOV AH, 09h
    INT 21h
    RET

LIST_FULL_ERR:
    LEA DX, MSG_FULL
    MOV AH, 09h
    INT 21h
    RET
ADD_CANDIDATE ENDP


VIEW_CANDIDATES PROC
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h

    CMP CAND_COUNT, 0
    JE NO_CANDS_VIEW

    LEA SI, CANDIDATES
    MOV CX, 5           ; Loop all possible slots
    
VIEW_LOOP:
    CMP BYTE PTR [SI], 0    ; Is this slot empty?
    JE SKIP_PRINT
    
    ; Print string at SI
    PUSH SI
    
PRINT_NAME_CHAR:
    LODSB               ; Load byte from DS:SI into AL
    CMP AL, 0
    JE DONE_PRINT_NAME
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    JMP PRINT_NAME_CHAR
    
DONE_PRINT_NAME:
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h
    POP SI

SKIP_PRINT:
    ADD SI, 20          ; Move to next slot
    LOOP VIEW_LOOP
    RET

NO_CANDS_VIEW:
    LEA DX, MSG_EMPTY_LIST
    MOV AH, 09h
    INT 21h
    RET
VIEW_CANDIDATES ENDP


SEARCH_CANDIDATE PROC
    LEA DX, MSG_SEARCH_PRPT
    MOV AH, 09h
    INT 21h
    
    CALL READ_STRING    ; Input goes to INPUT_BUFFER
    
    LEA SI, CANDIDATES  ; Array to search
    MOV CX, 5           ; Max slots
    
SEARCH_LOOP:
    CMP BYTE PTR [SI], 0
    JE SEARCH_NEXT      ; Skip empty slots
    
    ; Compare INPUT_BUFFER with string at SI
    PUSH SI             ; Save current slot ptr
    LEA DI, INPUT_BUFFER
    
    ; Inner Compare Routine
    PUSH SI
    PUSH DI
    
INNER_CMP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JNE INNER_MISMATCH
    CMP AL, 0
    JE FOUND_IT         ; End of both strings and equal
    INC SI
    INC DI
    JMP INNER_CMP
    
INNER_MISMATCH:
    POP DI
    POP SI
    POP SI              ; Restore outer loop SI
    JMP SEARCH_NEXT

FOUND_IT:
    POP DI
    POP SI              ; Clean stack
    POP SI              ; Clean stack
    LEA DX, MSG_FOUND
    MOV AH, 09h
    INT 21h
    RET

SEARCH_NEXT:
    ADD SI, 20
    LOOP SEARCH_LOOP
    
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09h
    INT 21h
    RET
SEARCH_CANDIDATE ENDP


REMOVE_CANDIDATE PROC
    LEA DX, MSG_DEL_PRPT
    MOV AH, 09h
    INT 21h
    
    CALL READ_STRING    ; Input in INPUT_BUFFER
    
    LEA SI, CANDIDATES
    MOV CX, 5
    
REMOVE_LOOP:
    CMP BYTE PTR [SI], 0
    JE REMOVE_NEXT
    
    PUSH SI
    LEA DI, INPUT_BUFFER
    
    ; Compare logic inline
    PUSH SI
    PUSH DI
RM_CMP_LOOP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JNE RM_MISMATCH
    CMP AL, 0
    JE DELETE_IT
    INC SI
    INC DI
    JMP RM_CMP_LOOP
    
RM_MISMATCH:
    POP DI
    POP SI
    POP SI
    JMP REMOVE_NEXT
    
DELETE_IT:
    POP DI
    POP SI
    POP SI              ; SI is now pointing to start of slot
    
    MOV BYTE PTR [SI], 0    ; Mark as empty
    DEC CAND_COUNT
    
    LEA DX, MSG_DELETED
    MOV AH, 09h
    INT 21h
    RET
    
REMOVE_NEXT:
    ADD SI, 20
    LOOP REMOVE_LOOP
    
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09h
    INT 21h
    RET
REMOVE_CANDIDATE ENDP

END MAIN
