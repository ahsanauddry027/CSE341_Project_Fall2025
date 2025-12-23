.MODEL SMALL
.STACK 100H

.DATA
    ; Login Variables
    PASSWORD        DB 'admin', 0       ; Hardcoded password (null terminated)
    INPUT_BUFFER    DB 20 DUP(0)        ; Buffer for user input
    LOGIN_ATTEMPTS  DB 0
    MAX_ATTEMPTS    DB 3
    
    ; Candidate Variables
    CANDIDATES      DB 100 DUP(0)   
    CAND_COUNT      DB 0
    MAX_CANDIDATES  DB 3
    CAND_NAME_LEN   DB 20
    
    ; Messages
    MSG_ENTER_PASS  DB 0Dh, 0Ah, 'Enter Password: $'
    MSG_WELCOME     DB 0Dh, 0Ah, 'Login Successful! Welcome Admin.', 0Dh, 0Ah, '$'
    MSG_WRONG_PASS  DB 0Dh, 0Ah, 'Invalid Password!', 0Dh, 0Ah, '$'
    MSG_LOCKED      DB 0Dh, 0Ah, 'SYSTEM LOCKED due to too many failed attempts.', 0Dh, 0Ah, '$'
    
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

    ; --- VOTER & VOTING VARIABLES ---
    VOTERS          DB 100 DUP(0)   ; 5 Voters * 20 chars
    VOTER_COUNT     DB 0
    MAX_VOTERS      DB 4
    VOTER_HAS_VOTED DB 5 DUP(0)     ; 0=No, 1=Yes
    CANDIDATE_VOTES DB 5 DUP(0)     ; Count
    TOTAL_VOTES_CAST DB 0           ; New total counter
    ELECTION_OVER   DB 0            ; Flag
    
    ; NEW: Voter Passwords
    ; 5 Voters, each password max 20 chars. Stored sequentially same as VOTERS names.
    VOTER_PASSWORDS DB 100 DUP(0)

    ; Voter Messages
    MSG_REG_NAME    DB 0Dh, 0Ah, 'Enter Voter Name: $'
    MSG_REG_PASS    DB 0Dh, 0Ah, 'Enter Password for Voter: $'    ; NEW
    MSG_REG_ID      DB 0Dh, 0Ah, 'Registered! Your Voter ID is: $'
    MSG_DUP_VOTER   DB 0Dh, 0Ah, 'Error: Voter already registered!', 0Dh, 0Ah, '$'
    MSG_VOTER_FULL  DB 0Dh, 0Ah, 'Error: Voter list full!', 0Dh, 0Ah, '$'
    
    ; Voting Messages
    MSG_VOTE_ID_PRPT DB 0Dh, 0Ah, 'Enter your Voter ID (1-4): $'
    MSG_VOTE_PW_PRPT DB 0Dh, 0Ah, 'Enter your Password: $'        ; NEW
    MSG_INVALID_ID   DB 0Dh, 0Ah, 'Error: Invalid Voter ID or Not Registered!', 0Dh, 0Ah, '$'
    MSG_ALREADY_VOTED DB 0Dh, 0Ah, 'Error: You have already voted!', 0Dh, 0Ah, '$'
    MSG_SEL_CAND     DB 0Dh, 0Ah, 'Enter Candidate Number to Vote For (1-3): $'
    MSG_VOTE_CAST    DB 0Dh, 0Ah, 'Vote Cast Successfully!', 0Dh, 0Ah, '$'
    MSG_IMM_WIN      DB 0Dh, 0Ah, 'Candidate Reached 3 Votes! ELECTION OVER.', 0Dh, 0Ah, '$'
    MSG_TIE_BREAK    DB 0Dh, 0Ah, 'TIE DETECTED! ADMIN must break the draw.', 0Dh, 0Ah, '$'
    MSG_ELEC_OVER_ERR DB 0Dh, 0Ah, 'Error: Election is already over!', 0Dh, 0Ah, '$'
    MSG_INV_CAND     DB 0Dh, 0Ah, 'Error: Invalid Candidate!', 0Dh, 0Ah, '$'
    MSG_SHOW_VOTES   DB ' - Votes: $'

    ; Edit Candidate Messages
    MSG_EDIT_ID     DB 0Dh, 0Ah, 'Enter Candidate ID to Edit (1-5): $'
    MSG_EDIT_NAME   DB 0Dh, 0Ah, 'Enter New Name: $'
    MSG_EDIT_SUCCESS DB 0Dh, 0Ah, 'Candidate Updated Successfully.', 0Dh, 0Ah, '$'

    ; Results Messages
    MSG_WINNER       DB 0Dh, 0Ah, 'Winner: $'
    MSG_TIE          DB 0Dh, 0Ah, 'It is a tie between: $'
    MSG_NO_VOTES     DB 0Dh, 0Ah, 'No votes cast yet.', 0Dh, 0Ah, '$'
    MSG_WITH_VOTES   DB ' with $'
    MSG_VOTES_TEXT   DB ' votes.', 0Dh, 0Ah, '$'

    ; --- SYSTEM MENUS ---
    MSG_SYS_MENU     DB 0Dh, 0Ah, 0Dh, 0Ah, '--- SYSTEM LOGIN ---', 0Dh, 0Ah
                     DB '1. Admin Login', 0Dh, 0Ah
                     DB '2. Voter Login', 0Dh, 0Ah
                     DB '3. Exit', 0Dh, 0Ah
                     DB 'Select option: $'

    MSG_MENU        DB 0Dh, 0Ah, 0Dh, 0Ah, '--- ADMIN MENU ---', 0Dh, 0Ah
                    DB '1. Add Candidate', 0Dh, 0Ah
                    DB '2. View Candidates', 0Dh, 0Ah
                    DB '3. Search Candidate', 0Dh, 0Ah
                    DB '4. Remove Candidate', 0Dh, 0Ah
                    DB '5. Logout', 0Dh, 0Ah
                    DB '6. Register Voter', 0Dh, 0Ah
                    DB '7. Show Results', 0Dh, 0Ah
                    DB '8. Edit Candidate', 0Dh, 0Ah
                    DB 'Select option: $'

    ; Note: Removed "7. Cast Vote" and "8. Show Results" from Admin Menu, updated accordingly.
    ; Admin registers voters, sees results. Cast vote is now VOTER ONLY.
    ; Previous "7. Cast Vote" logic moves to Voter Flow.

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; --- SYSTEM ENTRY POINT ---
SYSTEM_ENTRY:
    LEA DX, MSG_SYS_MENU
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01h
    INT 21h
    MOV BL, AL

    CMP BL, '1'
    JE ADMIN_LOGIN_FLOW
    CMP BL, '2'
    JE VOTER_LOGIN_FLOW
    CMP BL, '3'
    JE EXIT_PROGRAM
    JMP SYSTEM_ENTRY

    ; --- ADMIN FLOW ---
ADMIN_LOGIN_FLOW:
    MOV LOGIN_ATTEMPTS, 0 ; Reset attempts on fresh entry
    
ADMIN_LOG_LOOP:
    MOV AL, LOGIN_ATTEMPTS
    CMP AL, MAX_ATTEMPTS
    JAE SYSTEM_LOCK
    
    LEA DX, MSG_ENTER_PASS
    MOV AH, 09h
    INT 21h
    
    CALL READ_STRING
    LEA SI, INPUT_BUFFER
    LEA DI, PASSWORD
    CALL COMPARE_STRINGS
    CMP AX, 1
    JE ADMIN_SUCCESS
    
    LEA DX, MSG_WRONG_PASS
    MOV AH, 09h
    INT 21h
    INC LOGIN_ATTEMPTS
    JMP ADMIN_LOG_LOOP

ADMIN_SUCCESS:
    LEA DX, MSG_WELCOME
    MOV AH, 09h
    INT 21h

ADMIN_MENU_LOOP:
    LEA DX, MSG_MENU
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01h
    INT 21h
    MOV BL, AL
    
    CMP BL, '1'
    JE A_ADD
    CMP BL, '2'
    JE A_VIEW
    CMP BL, '3'
    JE A_SEARCH
    CMP BL, '4'
    JE A_REMOVE
    CMP BL, '5'
    JE SYSTEM_ENTRY ; Logout
    CMP BL, '6'
    JE A_REG_VOTER
    CMP BL, '7'
    JE A_RESULTS
    CMP BL, '8'
    JE A_EDIT_CAND
    
    JMP ADMIN_MENU_LOOP

A_ADD:
    CALL ADD_CANDIDATE
    JMP ADMIN_MENU_LOOP
A_VIEW:
    CALL VIEW_CANDIDATES
    JMP ADMIN_MENU_LOOP
A_SEARCH:
    CALL SEARCH_CANDIDATE
    JMP ADMIN_MENU_LOOP
A_REMOVE:
    CALL REMOVE_CANDIDATE
    JMP ADMIN_MENU_LOOP
A_REG_VOTER:
    CALL REGISTER_VOTER
    JMP ADMIN_MENU_LOOP
A_RESULTS:
    CALL SHOW_RESULTS
    JMP ADMIN_MENU_LOOP
A_EDIT_CAND:
    CALL EDIT_CANDIDATE
    JMP ADMIN_MENU_LOOP


    ; --- VOTER FLOW ---
VOTER_LOGIN_FLOW:
    MOV LOGIN_ATTEMPTS, 0 
    
    VOTER_LOG_LOOP:
    ; Check if election already over
    CMP ELECTION_OVER, 1
    JE ELECTION_ALREADY_OVER

    ; 1. Enter ID
    LEA DX, MSG_VOTE_ID_PRPT
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV BL, AL          ; Voter ID in BL
    
    ; Validate ID simple range
    CMP BL, 1
    JL VOTER_FAIL
    CMP BL, 4
    JG VOTER_FAIL
    
    ; 2. Enter Password
    LEA DX, MSG_VOTE_PW_PRPT
    MOV AH, 09h
    INT 21h
    
    CALL READ_STRING ; In INPUT_BUFFER
    
    ; 3. Verify ID exists & Password Matches
    ; Check attempts? We should track limits. 
    MOV AL, LOGIN_ATTEMPTS
    CMP AL, MAX_ATTEMPTS
    JAE SYSTEM_LOCK
    
    ; Calculate Offset: (ID-1) * 20
    XOR AH, AH
    MOV AL, BL
    DEC AL
    MOV CX, 20
    MUL CX
    MOV SI, AX ; Offset
    
    ; Check if Registered (Name not empty)
    LEA DI, VOTERS
    ADD DI, SI
    CMP BYTE PTR [DI], 0
    JE VOTER_FAIL_MSG
    
    ; Compare Passwords
    LEA DI, VOTER_PASSWORDS
    ADD DI, SI ; Password is at same offset
    
    ; Compare INPUT_BUFFER (SI) vs STORED (DI)
    ; But we need INPUT in SI and Stored in DI for our func? 
    ; Our func: SI, DI. 
    PUSH SI ; Save offset
    LEA SI, INPUT_BUFFER
    ; DI is already correct
    CALL COMPARE_STRINGS
    POP DX ; Restore offset into DX (was SI)
    
    CMP AX, 1
    JE VOTER_SUCCESS
    
VOTER_FAIL_MSG:
    LEA DX, MSG_WRONG_PASS
    MOV AH, 09h
    INT 21h
    INC LOGIN_ATTEMPTS
    JMP VOTER_LOG_LOOP

VOTER_FAIL:
    LEA DX, MSG_INVALID_ID
    MOV AH, 09h
    INT 21h
    JMP SYSTEM_ENTRY

VOTER_SUCCESS:
    ; Valid Login. Attempt Vote.
    ; DX still holds Offset from earlier push/pop? No, popped into DX
    ; We need the ID for CAST_VOTE logic. 
    ; Actually, CAST_VOTE currently ASKS for ID again.
    ; Ideally we pass the ID.
    ; Let's just call CAST_VOTE_LOGGED_IN. 
    ; We need to mod CAST_VOTE.
    ; For Simplicity: We will re-use BL (ID) if we saved it.
    ; BL holds ID.
    
    CALL VOTE_PROCESS_LOGGED_IN
    JMP SYSTEM_ENTRY

ELECTION_ALREADY_OVER:
    LEA DX, MSG_ELEC_OVER_ERR
    MOV AH, 09h
    INT 21h
    JMP SYSTEM_ENTRY

SYSTEM_LOCK:
    LEA DX, MSG_LOCKED
    MOV AH, 09h
    INT 21h
    JMP EXIT_PROGRAM

EXIT_PROGRAM:
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; -----------------------------------------------------
; PROCEDURES
; -----------------------------------------------------

READ_STRING PROC
    PUSH AX
    PUSH BX
    PUSH SI
    LEA SI, INPUT_BUFFER
READ_CHAR_LOOP:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE END_READ
    MOV [SI], AL
    INC SI
    JMP READ_CHAR_LOOP
END_READ:
    MOV [SI], 0
    POP SI
    POP BX
    POP AX
    RET
READ_STRING ENDP

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
    CMP BL, 0
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

ADD_CANDIDATE PROC
    MOV AL, CAND_COUNT
    CMP AL, MAX_CANDIDATES
    JAE LIST_FULL_ERR
    
    LEA DX, MSG_ADD_NAME
    MOV AH, 09h
    INT 21h
    
    LEA DI, CANDIDATES
    MOV CX, 3
    MOV DX, 20
    MOV BX, 1
FIND_EMPTY_SLOT:
    CMP BYTE PTR [DI], 0
    JE READ_INTO_SLOT
    ADD DI, 20
    INC BX
    LOOP FIND_EMPTY_SLOT
    JMP LIST_FULL_ERR 

READ_INTO_SLOT:
    PUSH DI
READ_CAND_LOOP:
    MOV AH, 01h
    INT 21h
    CMP AL, 0Dh
    JE FINISH_ADD
    MOV [DI], AL
    INC DI
    JMP READ_CAND_LOOP
FINISH_ADD:
    MOV BYTE PTR [DI], 0
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
    LEA DI, CANDIDATE_VOTES
    MOV CX, 3
    MOV BX, 1
VIEW_LOOP:
    CMP BYTE PTR [SI], 0
    JE SKIP_PRINT
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    MOV DL, '.'
    INT 21h
    MOV DL, ' '
    INT 21h
    PUSH SI
PRINT_NAME_CHAR:
    LODSB
    CMP AL, 0
    JE DONE_PRINT_NAME
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    JMP PRINT_NAME_CHAR
DONE_PRINT_NAME:
    POP SI
    LEA DX, MSG_SHOW_VOTES
    MOV AH, 09h
    INT 21h
    MOV AL, [DI]
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h
SKIP_PRINT:
    ADD SI, 20
    INC DI
    INC BX
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
    CALL READ_STRING
    LEA SI, CANDIDATES
    MOV CX, 3
SEARCH_LOOP:
    CMP BYTE PTR [SI], 0
    JE SEARCH_NEXT
    PUSH SI
    LEA DI, INPUT_BUFFER
    PUSH SI
    PUSH DI
INNER_CMP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JNE INNER_MISMATCH
    CMP AL, 0
    JE FOUND_IT
    INC SI
    INC DI
    JMP INNER_CMP
INNER_MISMATCH:
    POP DI
    POP SI
    POP SI
    JMP SEARCH_NEXT
FOUND_IT:
    POP DI
    POP SI
    POP SI
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
    CALL READ_STRING
    LEA SI, CANDIDATES
    MOV CX, 3
REMOVE_LOOP:
    CMP BYTE PTR [SI], 0
    JE REMOVE_NEXT
    PUSH SI
    LEA DI, INPUT_BUFFER
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
    POP SI
    MOV BYTE PTR [SI], 0
    DEC CAND_COUNT
    ; Zero vote count
    LEA AX, CANDIDATES
    MOV BX, SI
    SUB BX, AX
    MOV AX, BX
    MOV CL, 20
    DIV CL
    XOR AH, AH
    LEA DI, CANDIDATE_VOTES
    ADD DI, AX
    MOV BYTE PTR [DI], 0
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

REGISTER_VOTER PROC
    MOV AL, VOTER_COUNT
    CMP AL, MAX_VOTERS
    JAE VOTER_FULL_ERR
    
    LEA DX, MSG_REG_NAME
    MOV AH, 09h
    INT 21h
    CALL READ_STRING
    
    ; Duplicate Check
    LEA SI, VOTERS
    MOV CX, 4
CHECK_DUP_LOOP:
    CMP BYTE PTR [SI], 0
    JE CHECK_NEXT_VOTER
    PUSH SI
    LEA DI, INPUT_BUFFER
    PUSH SI
    PUSH DI
DUP_CMP:
    MOV AL, [SI]
    MOV AH, [DI]
    CMP AL, AH
    JNE DUP_MISMATCH
    CMP AL, 0
    JE IS_DUPLICATE
    INC SI
    INC DI
    JMP DUP_CMP
DUP_MISMATCH:
    POP DI
    POP SI
    POP SI
    JMP CHECK_NEXT_VOTER
IS_DUPLICATE:
    POP DI
    POP SI
    POP SI
    LEA DX, MSG_DUP_VOTER
    MOV AH, 09h
    INT 21h
    RET
CHECK_NEXT_VOTER:
    ADD SI, 20
    LOOP CHECK_DUP_LOOP
    
    ; Find Slot
    LEA DI, VOTERS
    MOV CX, 4
    MOV BX, 1
FIND_V_SLOT:
    CMP BYTE PTR [DI], 0
    JE WRITE_VOTER
    ADD DI, 20
    INC BX
    LOOP FIND_V_SLOT
    JMP VOTER_FULL_ERR 

WRITE_VOTER:
    ; 1. Write Name
    PUSH DI
    LEA SI, INPUT_BUFFER
COPY_V_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    CMP AL, 0
    JE DONE_COPY_V
    INC SI
    INC DI
    JMP COPY_V_LOOP
DONE_COPY_V:
    POP DI
    
    ; 2. Ask & Write Password (NEW)
    ; DI points to name slot. We need Password slot.
    ; Calulate Offset from DI: (DI - VOTERS) -> same offset in VOTER_PASSWORDS
    LEA AX, VOTERS
    MOV SI, DI
    SUB SI, AX ; SI = offset
    
    LEA DX, MSG_REG_PASS
    MOV AH, 09h
    INT 21h
    
    CALL READ_STRING ; In INPUT_BUFFER
    
    LEA DI, VOTER_PASSWORDS
    ADD DI, SI ; Point to correct password slot
    
    ; Copy Password
    PUSH DI
    LEA SI, INPUT_BUFFER
COPY_P_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    CMP AL, 0
    JE DONE_COPY_P
    INC SI
    INC DI
    JMP COPY_P_LOOP
DONE_COPY_P:
    POP DI

    INC VOTER_COUNT
    LEA DX, MSG_REG_ID
    MOV AH, 09h
    INT 21h
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LEA DX, NEWLINE
    MOV AH, 09h
    INT 21h
    RET
VOTER_FULL_ERR:
    LEA DX, MSG_VOTER_FULL
    MOV AH, 09h
    INT 21h
    RET
REGISTER_VOTER ENDP


; MODIFIED: Runs when already logged in. BL = Voter ID (1-5)
VOTE_PROCESS_LOGGED_IN PROC
    ; Check ALREADY VOTED (Feature 5) - redundant double check but good safety
    XOR AH, AH
    MOV AL, BL
    DEC AL
    MOV SI, AX ; 0-based index
    
    LEA DI, VOTER_HAS_VOTED
    ADD DI, SI
    CMP BYTE PTR [DI], 1
    JE ALREADY_VOTED_ERR_VP
    
    PUSH DI ; Save HAS_VOTED ptr
    
    CALL VIEW_CANDIDATES
    
    LEA DX, MSG_SEL_CAND
    MOV AH, 09h
    INT 21h
    
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV CL, AL ; Cand ID
    
    CMP CL, 1
    JL INV_CAND_ERR_VP
    CMP CL, 3
    JG INV_CAND_ERR_VP
    
    ; Check Cand Exist
    XOR CH, CH
    MOV BL, CL
    DEC BL
    MOV AX, 20
    MUL BL
    LEA SI, CANDIDATES
    ADD SI, AX
    CMP BYTE PTR [SI], 0
    JE INV_CAND_ERR_VP
    
    ; Update Vote
    XOR CH, CH
    DEC CL
    LEA SI, CANDIDATE_VOTES
    ADD SI, CX
    INC BYTE PTR [SI]
    
    POP DI
    MOV BYTE PTR [DI], 1
    
    LEA DX, MSG_VOTE_CAST
    MOV AH, 09h
    INT 21h

    INC TOTAL_VOTES_CAST
    
    ; Check Immediate Win (3 votes)
    CMP BYTE PTR [SI], 3
    JE WIN_BY_3
    
    ; Check if 4 votes cast and no winner (must be a tie)
    CMP TOTAL_VOTES_CAST, 4
    JE TIE_CASE
    
    RET

WIN_BY_3:
    MOV ELECTION_OVER, 1
    LEA DX, MSG_IMM_WIN
    MOV AH, 09h
    INT 21h
    CALL SHOW_RESULTS
    RET

TIE_CASE:
    LEA DX, MSG_TIE_BREAK
    MOV AH, 09h
    INT 21h
    
    CALL VIEW_CANDIDATES
    LEA DX, MSG_SEL_CAND
    MOV AH, 09h
    INT 21h
    
    ; Admin Vote
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV CL, AL
    
    CMP CL, 1
    JL INV_CAND_ERR_VP ; Simplification: reuse err
    CMP CL, 3
    JG INV_CAND_ERR_VP
    
    XOR CH, CH
    DEC CL
    LEA SI, CANDIDATE_VOTES
    ADD SI, CX
    INC BYTE PTR [SI]
    
    MOV ELECTION_OVER, 1
    LEA DX, MSG_VOTE_CAST
    MOV AH, 09h
    INT 21h
    CALL SHOW_RESULTS
    RET

ALREADY_VOTED_ERR_VP:
    LEA DX, MSG_ALREADY_VOTED
    MOV AH, 09h
    INT 21h
    RET
INV_CAND_ERR_VP:
    POP DI
    LEA DX, MSG_INV_CAND
    MOV AH, 09h
    INT 21h
    RET
VOTE_PROCESS_LOGGED_IN ENDP


SHOW_RESULTS PROC
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    LEA SI, CANDIDATE_VOTES
    MOV CX, 3
    MOV BL, 0 
FIND_MAX_LOOP:
    MOV AL, [SI]
    CMP AL, BL
    JBE SKIP_MAX_UPDATE
    MOV BL, AL 
SKIP_MAX_UPDATE:
    INC SI
    LOOP FIND_MAX_LOOP
    CMP BL, 0
    JE NO_VOTES_YET
    LEA SI, CANDIDATE_VOTES
    MOV CX, 3
    MOV BH, 0 
COUNT_WINNERS:
    MOV AL, [SI]
    CMP AL, BL
    JNE NEXT_CAND_COUNT
    INC BH
NEXT_CAND_COUNT:
    INC SI
    LOOP COUNT_WINNERS
    CMP BH, 1
    JA IT_IS_A_TIE
    LEA DX, MSG_WINNER
    MOV AH, 09H
    INT 21H
    JMP PRINT_WINNERS
IT_IS_A_TIE:
    LEA DX, MSG_TIE
    MOV AH, 09H
    INT 21H
PRINT_WINNERS:
    LEA SI, CANDIDATE_VOTES
    MOV CX, 3
    MOV AH, 0 
PRINT_AGAIN_LOOP:
    PUSH CX
    MOV AL, [SI]
    CMP AL, BL
    JNE SKIP_PRINT_WINNER
    PUSH AX
    PUSH BX
    MOV AL, AH
    MOV CL, 20
    MUL CL
    LEA DI, CANDIDATES
    ADD DI, AX
    MOV DX, DI 
    PUSH SI
    MOV SI, DI
P_WIN_NAME:
    LODSB
    CMP AL, 0
    JE END_P_WIN_NAME
    MOV DL, AL
    MOV AH, 02h
    INT 21H
    JMP P_WIN_NAME
END_P_WIN_NAME:
    POP SI
    MOV DL, ' '
    MOV AH, 02h
    INT 21H
    POP BX
    POP AX
SKIP_PRINT_WINNER:
    INC SI
    INC AH 
    POP CX
    LOOP PRINT_AGAIN_LOOP
    LEA DX, MSG_WITH_VOTES
    MOV AH, 09H
    INT 21H
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LEA DX, MSG_VOTES_TEXT
    MOV AH, 09H
    INT 21H
    RET
NO_VOTES_YET:
    LEA DX, MSG_NO_VOTES
    MOV AH, 09H
    INT 21H
    RET
SHOW_RESULTS ENDP

EDIT_CANDIDATE PROC
    LEA DX, MSG_EDIT_ID
    MOV AH, 09h
    INT 21h

    ; Read ID char
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV BL, AL          ; Store ID in BL

    ; Validate ID (1-5)
    CMP BL, 1
    JL INV_CAND_ERR_EDIT
    CMP BL, 5
    JG INV_CAND_ERR_EDIT

    ; Calc Index: (ID-1) * 20
    XOR AH, AH
    MOV AL, BL
    DEC AL
    MOV SI, AX
    MOV AX, 20
    MUL SI              ; AX = offset
    MOV SI, AX
    
    LEA DI, CANDIDATES
    ADD DI, SI          ; DI points to candidate slot
    
    ; Check if exists
    CMP BYTE PTR [DI], 0
    JE INV_CAND_ERR_EDIT
    
    ; Prompt New Name
    LEA DX, MSG_EDIT_NAME
    MOV AH, 09h
    INT 21h
    
    ; Read new name into INPUT_BUFFER
    CALL READ_STRING
    
    ; Overwrite Slot with INPUT_BUFFER
    PUSH DI
    LEA SI, INPUT_BUFFER
    
COPY_EDIT_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    CMP AL, 0
    JE DONE_EDIT_COPY
    INC SI
    INC DI
    JMP COPY_EDIT_LOOP
    
DONE_EDIT_COPY:
    POP DI
    LEA DX, MSG_EDIT_SUCCESS
    MOV AH, 09h
    INT 21h
    RET

INV_CAND_ERR_EDIT:
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09h
    INT 21h
    RET
EDIT_CANDIDATE ENDP

END MAIN
