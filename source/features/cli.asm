; ==================================================================
; MikeOS -- The Mike Operating System kernel
; Copyright (C) 2006 - 2019 MikeOS Developers -- see doc/LICENSE.TXT
; GMU OS derivative learning edition: GM University, Davanagere, 2026
;
; COMMAND LINE INTERFACE
; ==================================================================


os_command_line:
	call os_clear_screen

	mov si, version_msg
	call os_print_string
	mov si, help_text
	call os_print_string


get_cmd:				; Main processing loop
	mov di, command			; Clear single command buffer
	mov cx, 32
	rep stosb

	mov si, prompt			; Main loop; prompt for input
	call os_print_string

	mov ax, input			; Get command string from user
	mov bx, 64
	call os_input_string

	call os_print_newline

	mov ax, input			; Remove trailing spaces
	call os_string_chomp

	mov si, input			; If just enter pressed, prompt again
	cmp byte [si], 0
	je get_cmd

	mov si, input			; Separate out the individual command
	mov al, ' '
	call os_string_tokenize

	mov word [param_list], di	; Store location of full parameters

	mov si, input			; Store copy of command for later modifications
	mov di, command
	call os_string_copy



	; First, let's check to see if it's an internal command...

	mov ax, input
	call os_string_uppercase

	mov si, input

	mov di, exit_string		; 'EXIT' entered?
	call os_string_compare
	jc near exit

	mov di, help_string		; 'HELP' entered?
	call os_string_compare
	jc near print_help

	mov di, cls_string		; 'CLS' entered?
	call os_string_compare
	jc near clear_screen

	mov di, dir_string		; 'DIR' entered?
	call os_string_compare
	jc near list_directory

	mov di, ver_string		; 'VER' entered?
	call os_string_compare
	jc near print_ver

	mov di, about_string		; 'ABOUT' entered?
	call os_string_compare
	jc near print_about

	mov di, time_string		; 'TIME' entered?
	call os_string_compare
	jc near print_time

	mov di, date_string		; 'DATE' entered?
	call os_string_compare
	jc near print_date

	mov di, cat_string		; 'CAT' entered?
	call os_string_compare
	jc near cat_file

	mov di, del_string		; 'DEL' entered?
	call os_string_compare
	jc near del_file

	mov di, copy_string		; 'COPY' entered?
	call os_string_compare
	jc near copy_file

	mov di, ren_string		; 'REN' entered?
	call os_string_compare
	jc near ren_file

	mov di, size_string		; 'SIZE' entered?
	call os_string_compare
	jc near size_file

	mov di, list_string		; 'LS' entered?
	call os_string_compare
	jc dir_list


	; If the user hasn't entered any of the above commands, then we
	; need to check for an executable file -- .BIN or .BAS, and the
	; user may not have provided the extension

	mov ax, command
	call os_string_uppercase
	call os_string_length


	; If the user has entered, say, MEGACOOL.BIN, we want to find that .BIN
	; bit, so we get the length of the command, go four characters back to
	; the full stop, and start searching from there

	mov si, command
	add si, ax

	sub si, 4

	mov di, bin_extension		; Is there a .BIN extension?
	call os_string_compare
	jc bin_file

	mov di, bas_extension		; Or is there a .BAS extension?
	call os_string_compare
	jc bas_file

	mov di, pcx_extension		; Or is there a .PCX extension?
	call os_string_compare
	jc total_fail

	jmp no_extension


bin_file:
	mov ax, command
	mov bx, 0
	mov cx, 32768
	call os_load_file
	jc total_fail

execute_bin:
	mov si, command
	mov di, kern_file_string
	mov cx, 6
	call os_string_strincmp
	jc no_kernel_allowed

	mov ax, 0			; Clear all registers
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov word si, [param_list]
	mov di, 0

	call 32768			; Call the external program

	jmp get_cmd			; When program has finished, start again



bas_file:
	mov ax, command
	mov bx, 0
	mov cx, 32768
	call os_load_file
	jc total_fail

	mov ax, 32768
	mov word si, [param_list]
	call os_run_basic

	jmp get_cmd



no_extension:
	mov ax, command
	call os_string_length

	mov si, command
	add si, ax

	mov byte [si], '.'
	mov byte [si+1], 'B'
	mov byte [si+2], 'I'
	mov byte [si+3], 'N'
	mov byte [si+4], 0

	mov ax, command
	mov bx, 0
	mov cx, 32768
	call os_load_file
	jc try_bas_ext

	jmp execute_bin


try_bas_ext:
	mov ax, command
	call os_string_length

	mov si, command
	add si, ax
	sub si, 4

	mov byte [si], '.'
	mov byte [si+1], 'B'
	mov byte [si+2], 'A'
	mov byte [si+3], 'S'
	mov byte [si+4], 0

	jmp bas_file



total_fail:
	mov si, invalid_msg
	call os_print_string

	jmp get_cmd


no_kernel_allowed:
	mov si, kern_warn_msg
	call os_print_string

	jmp get_cmd


; ------------------------------------------------------------------

print_help:
	mov si, help_text
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

clear_screen:
	call os_clear_screen
	jmp get_cmd


; ------------------------------------------------------------------

print_time:
	mov bx, tmp_string
	call os_get_time_string
	mov si, bx
	call os_print_string
	call os_print_newline
	jmp get_cmd


; ------------------------------------------------------------------

print_date:
	mov bx, tmp_string
	call os_get_date_string
	mov si, bx
	call os_print_string
	call os_print_newline
	jmp get_cmd


; ------------------------------------------------------------------

print_ver:
	mov si, version_msg
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

print_about:
	mov si, about_text
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

kern_warning:
	mov si, kern_warn_msg
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

list_directory:
	push es
	push ds
	pop es				; Guarantee ES == DS = 0x2000
	pusha

	; Reset memory-backed state
	mov word [dir_file_count], 0
	mov byte [dir_col_state], 0

	; Read root directory (14 sectors) into disk_buffer
	call disk_read_root_dir
	jnc .read_ok
	mov si, dir_readfail_msg
	call os_print_string
	jmp .done

.read_ok:
	mov di, disk_buffer		; Point ES:DI to root directory buffer

	; Print Table Header (61 chars)
	mov si, dir_header_1
	call os_print_string
	mov si, dir_header_2
	call os_print_string

.entry_loop:
	; Strict boundary check: 14 sectors * 512 bytes = 7168 bytes
	cmp di, disk_buffer + 7168
	jae .finish

	; Re-verify ES matches DS before memory access
	push ds
	pop es

	; Filter: Attribute byte [es:di+11]
	mov al, [es:di+11]
	cmp al, 0Fh			; Skip VFAT LFN
	je .next_entry
	test al, 18h			; Skip subdirectories (10h) & volume labels (08h)
	jnz .next_entry

	; Filter: First character [es:di]
	mov al, [es:di]
	cmp al, 0			; 0 = entry never used (end of directory)
	je .finish
	cmp al, 0E5h			; E5h = deleted file entry
	je .next_entry
	cmp al, ' '			; Skip invalid / control chars
	jle .next_entry
	cmp al, '~'			; Skip non-printable ASCII
	ja .next_entry
	cmp al, '.'			; Skip dot entries
	je .next_entry

	; Valid file found -> increment memory-backed counter
	inc word [dir_file_count]

	; Check column state (0 = left column, 1 = right column)
	cmp byte [dir_col_state], 0
	jne .do_right

	; --- LEFT COLUMN OUTPUT (28 chars + 7-char divider) ---
	call os_print_space
	call os_print_space		; 2-char leading indent (cols 0..1)
	call dir_print_name_12		; 8.3 filename padded to 12 chars (cols 2..13)
	call os_print_space
	call os_print_space		; 2-char spacer (cols 14..15)
	call dir_print_size_12		; 32-bit size right-aligned to 10 chars + " B" (cols 16..27)
	mov si, dir_divider		; "   |   " (cols 28..34, bar at col 31)
	call os_print_string
	mov byte [dir_col_state], 1	; Switch to right column
	jmp .next_entry

.do_right:
	; --- RIGHT COLUMN OUTPUT (26 chars) ---
	call dir_print_name_12		; 8.3 filename padded to 12 chars (cols 35..46)
	call os_print_space
	call os_print_space		; 2-char spacer (cols 47..48)
	call dir_print_size_12		; 32-bit size right-aligned to 10 chars + " B" (cols 49..60)
	call os_print_newline		; Advance to next display row
	mov byte [dir_col_state], 0	; Switch to left column

.next_entry:
	add di, 32			; Advance by 32-byte FAT12 entry stride
	jmp .entry_loop

.finish:
	; If odd number of files, emit newline so summary starts on fresh line
	cmp byte [dir_col_state], 1
	jne .print_summary
	call os_print_newline

.print_summary:
	mov si, dir_summary_div		; 59-dash rule (cols 2..60)
	call os_print_string

	cmp word [dir_file_count], 0
	jne .show_total
	mov si, dir_empty_msg		; "  No files found on disk."
	call os_print_string
	jmp .done

.show_total:
	mov si, dir_summary_pre		; "  Total: "
	call os_print_string
	mov ax, [dir_file_count]
	call os_int_to_string		; OUT: AX = pointer to string in .t
	mov si, ax
	call os_print_string		; Print numeric count
	mov si, dir_summary_post	; " file(s) found."
	call os_print_string

.done:
	popa
	pop es
	jmp get_cmd


; ------------------------------------------------------------------
; Helper: Print 8.3 filename from [ES:DI] padded to exactly 12 chars
; IN: ES:DI = directory entry pointer. OUT: All registers preserved.
dir_print_name_12:
	pusha
	xor dx, dx			; DL = characters printed counter
	mov bx, di
	add bx, 8			; BX points to 3-char extension
	mov cx, 8			; 8 characters max for base name

.name_loop:
	mov al, [es:di]
	inc di
	cmp al, ' '
	je .check_ext
	call .emit_char
	loop .name_loop

.check_ext:
	cmp byte [es:bx], ' '		; Check if valid extension exists
	jle .pad_spaces
	mov al, '.'
	call .emit_char
	mov di, bx
	mov cx, 3

.ext_loop:
	mov al, [es:di]
	inc di
	cmp al, ' '
	jle .pad_spaces
	call .emit_char
	loop .ext_loop

.pad_spaces:
	cmp dl, 12
	jae .name_done
	call os_print_space
	inc dl
	jmp .pad_spaces

.emit_char:
	mov ah, 0Eh
	push dx
	int 10h
	pop dx
	inc dl
	ret

.name_done:
	popa
	ret


; ------------------------------------------------------------------
; Helper: Print 32-bit file size from [ES:DI+28] right-aligned to 10 chars + " B"
; IN: ES:DI = directory entry pointer. OUT: All registers preserved.
dir_print_size_12:
	pusha
	push es
	push ds
	pop es				; Ensure ES == DS for string operations

	mov ax, [es:di+28]		; Low word of 32-bit size
	mov dx, [es:di+30]		; High word of 32-bit size
	mov bx, 10			; Base 10 decimal conversion
	mov di, dir_size_buf		; Static 16-byte destination buffer in DS
	call os_long_int_to_string	; Converts DX:AX -> [DI], DI is preserved by popa

	mov ax, di			; IN for os_string_length is AX
	call os_string_length		; OUT: AX = length of converted string

	neg ax
	add ax, 10			; 10 - length = number of leading spaces
	jle .no_padding			; If length >= 10, skip space padding
	mov cx, ax
.pad_loop:
	call os_print_space
	loop .pad_loop

.no_padding:
	mov si, dir_size_buf
	call os_print_string		; Print numeric string
	mov si, dir_bytes_unit		; " B"
	call os_print_string

	pop es
	popa
	ret


; ------------------------------------------------------------------

cat_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, nofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_file_exists		; Check if file exists
	jc .not_found

	mov cx, 32768			; Load file into second 32K
	call os_load_file

	mov word [file_size], bx

	cmp bx, 0			; Nothing in the file?
	je get_cmd

	mov si, 32768
	mov ah, 0Eh			; int 10h teletype function
.loop:
	lodsb				; Get byte from loaded file

	cmp al, 0Ah			; Move to start of line if we get a newline char
	jne .not_newline

	call os_get_cursor_pos
	mov dl, 0
	call os_move_cursor

.not_newline:
	int 10h				; Display it
	dec bx				; Count down file size
	cmp bx, 0			; End of file?
	jne .loop

	jmp get_cmd

.not_found:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd


; ------------------------------------------------------------------

del_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, nofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_remove_file
	jc .failure

	mov si, .success_msg
	call os_print_string
	mov si, ax
	call os_print_string
	call os_print_newline
	jmp get_cmd

.failure:
	mov si, .failure_msg
	call os_print_string
	jmp get_cmd


	.success_msg	db 'Deleted file: ', 0
	.failure_msg	db 'Could not delete file - does not exist or write protected', 13, 10, 0


; ------------------------------------------------------------------

size_file:
	mov word si, [param_list]
	call os_string_parse
	cmp ax, 0			; Was a filename provided?
	jne .filename_provided

	mov si, nofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	call os_get_file_size
	jc .failure

	mov si, .size_msg
	call os_print_string

	mov ax, bx
	call os_int_to_string
	mov si, ax
	call os_print_string
	call os_print_newline
	jmp get_cmd


.failure:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd


	.size_msg	db 'Size (in bytes) is: ', 0


; ------------------------------------------------------------------

copy_file:
	mov word si, [param_list]
	call os_string_parse
	mov word [.tmp], bx

	cmp bx, 0			; Were two filenames provided?
	jne .filename_provided

	mov si, nofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	mov dx, ax			; Store first filename temporarily
	mov ax, bx
	call os_file_exists
	jnc .already_exists

	mov ax, dx
	mov cx, 32768
	call os_load_file
	jc .load_fail

	mov cx, bx
	mov bx, 32768
	mov word ax, [.tmp]
	call os_write_file
	jc .write_fail

	mov si, .success_msg
	call os_print_string
	jmp get_cmd

.load_fail:
	mov si, notfound_msg
	call os_print_string
	jmp get_cmd

.write_fail:
	mov si, writefail_msg
	call os_print_string
	jmp get_cmd

.already_exists:
	mov si, exists_msg
	call os_print_string
	jmp get_cmd


	.tmp		dw 0
	.success_msg	db 'File copied successfully', 13, 10, 0


; ------------------------------------------------------------------

ren_file:
	mov word si, [param_list]
	call os_string_parse

	cmp bx, 0			; Were two filenames provided?
	jne .filename_provided

	mov si, nofilename_msg		; If not, show error message
	call os_print_string
	jmp get_cmd

.filename_provided:
	mov cx, ax			; Store first filename temporarily
	mov ax, bx			; Get destination
	call os_file_exists		; Check to see if it exists
	jnc .already_exists

	mov ax, cx			; Get first filename back
	call os_rename_file
	jc .failure

	mov si, .success_msg
	call os_print_string
	jmp get_cmd

.already_exists:
	mov si, exists_msg
	call os_print_string
	jmp get_cmd

.failure:
	mov si, .failure_msg
	call os_print_string
	jmp get_cmd


	.success_msg	db 'File renamed successfully', 13, 10, 0
	.failure_msg	db 'Operation failed - file not found or invalid filename', 13, 10, 0


; =====================================================================

ParaPerEntry	equ 2			; 32 bytes/entry => 2 paragraphs

dir_list:
	push es
	pusha

	call disk_read_root_dir
	jnc .cont1
	mov si, .readfail_msg
	call os_print_string
	jmp short .done

  .cont1:
;	mov di, bx			; ES:DI points to directory buffer
	mov di, disk_buffer		; ES:DI points to directory buffer

  .outer_loop:
	mov si, .header_msg
	call os_print_string
	mov cx, 20

  .page_loop:
	mov al, [es:di+11]		; get attributes
	cmp al, 0x0f			; Win marker
	je .next_entry

	test al, 0x18			; directory or volume label => skip
	jnz .next_entry

	mov al, [es:di]			; first char of name
	cmp al, 0			; first unused, should be unused here to end
	je .done

	cmp al, 0x5e			; skip deleted
	je .next_entry

	cmp al, ' '			; skip if starts with space or control (Win UTF-8?)
	jle .next_entry

	cmp al, '~'			; skip if not normal 7-bit ASCII
	jae .next_entry

	cmp al, '.'			; skip if '.' or '..'
	je .next_entry

	call dir_entry_dump		; ES:DI points to entry
	dec cx

  .next_entry:
	mov dx, es
	add dx, ParaPerEntry
	mov es, dx

	cmp cx, 0
	jne .page_loop

  .cont2:
	mov si, .footer_msg
	call os_print_string
	call os_wait_for_key
	cmp al, 27			; was key <esc>?
	je .done
	call os_clear_screen
	jmp .outer_loop

  .done:
	call os_print_newline
	popa
	pop es
	jmp get_cmd


	.readfail_msg	db 'Unable to read disk directory', 0
	.header_msg	db '    Name         attr         created          last write      first     bytes', 13, 10, 0
	.footer_msg	db 'Press key for next page', 0


; ---------------------------------------------------------------------
; listing helper subroutines

; ------------------------------------------------------------------
; dir_entry_dump -- print out the contents of a directory entry
;   output must correspond to header (above)
; IN: ES:DI = points to directory entry
; OUT: no changes

dir_entry_dump:
	pusha

	call type_name
	call os_get_cursor_pos		; line up columns
	mov dl, 15
	call os_move_cursor

	mov bh, [es:di+11]		; display attributes
	mov ax, 0x0e2e			; '.'
	test bh, 0x80			; reserved (should not be set)
	jz .attr1
	mov al, '*'
  .attr1:
	int 10h
	mov ax, 0x0e2e
	test bh, 0x40			; internal only (should not be set)
	jz .attr2
	mov al, '*'
  .attr2:
	int 10h
	mov ax, 0x0e2e
	test bh, 0x20
	jz .attr3
	mov al, 'A'			; archive
  .attr3:
	int 10h
	mov ax, 0x0e2e
	test bh, 0x10
	jz .attr4
	mov al, 'D'			; subdirectory
  .attr4:
	int 10h
	mov ax, 0x0e2e
	test bh, 8
	jz .attr5
	mov al, 'V'			; volume ID
  .attr5:
	int 10h
	mov ax, 0x0e2e
	test bh, 4
	jz .attr6
	mov al, 'S'			; system
  .attr6:
	int 10h
	mov ax, 0x0e2e
	test bh, 2
	jz .attr7
	mov al, 'H'			; hidden
  .attr7:
	int 10h
	mov ax, 0x0e2e
	test bh, 1
	jz .attr8
	mov al, 'R'			; read only
  .attr8:
	int 10h
	call os_print_space
	call os_print_space		; at column 25?

	mov dx, [es:di+16]		; created date & time (US and 24-hr format)
	call type_date
	call os_print_space
	mov dx, [es:di+14]
	call type_time
	call os_print_space
	call os_print_space		; at column 44?

	mov dx, [es:di+24]		; last written date & time (US and 24-hr format)
	call type_date
	call os_print_space
	mov dx, [es:di+22]
	call type_time			; at column 61?

	mov ax, [es:di+26]		; starting cluster
	call os_int_to_string
	mov si, ax
	call os_string_length
	neg ax
	add ax, 7			; 2 space separation + 5 characters, max.
	mov cx, ax
	jle .cluster_left
  .loop1:
	call os_print_space
	loop .loop1
  .cluster_left:
	call os_print_string

	mov dx, [es:di+30]		; file size (bytes)
	mov ax, [es:di+28]
	push es
	push ds
	pop es				; ES = DS = program seg
	push di
	mov bx, 10
	mov di, .number
	call os_long_int_to_string
	mov si, di
	mov ax, di
	call os_string_length
	neg ax
	add ax, 10			; 2 space separation + 8 characters, max.
	mov cx, ax
	jle .size_left
  .loop2:
	call os_print_space
	loop .loop2
  .size_left:
	call os_print_string
	call os_print_newline
	pop di
	pop es				; ES = directory seg

	popa
	ret

	.number		times 13 db 0

; ---------------------------------------------------------------------
; Type directory format time and print in 24-hr format (hh:mm:ss)
; There is a normal 2 second granularity
; IN: DX = time number
type_time:
	pusha

	mov ax, dx
	shr ax, 11			; 11 (start in word)
	cmp al, 10			; always 'hh'
	jae .hh
	push ax
	mov ax, 0x0e30			; '0'
	int 10h
	pop ax
  .hh:
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov ax, 0x0e3a			; ':'
	int 10h

	mov ax, dx
	shr ax, 5			; 5 bits for seconds/2
	and ax, 0x3f			; 6 bits for minutes
	cmp al, 10
	jae .mm
	push ax
	mov ax, 0x0e30
	int 10h
	pop ax
  .mm:
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov ax, 0x0e3a
	int 10h

	mov ax, dx
	and ax, 0x1f			; 5 bits for seconds/2
	shl ax, 1
	cmp al, 10
	jae .ss
	push ax
	mov ax, 0x0e30
	int 10h
	pop ax
  .ss:
	call os_int_to_string
	mov si, ax
	call os_print_string

	popa
	ret

; DOS format directory entry
; IN: DX = date number
; Uses USA date output format mm/dd/yy
type_date:
	pusha
	mov ax, dx		; separate out month
	shr ax, 5
	and ax, 0x0F
	cmp al, 1
	jl .mon_00
	cmp al, 12
	jbe .month
  .mon_00:
	mov al, 0
  .month:
	cmp al,10		; always 'mm'
	jge .mm
	push ax
	mov ax, 0x0e30
	int 10h
	pop ax
  .mm:
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov ax, 0x0e2f		; '/'
	int 10h

	mov ax,dx		; separate out day
	and ax,0x1F
	cmp al, 10		; always 'dd'
	jae .dd
	push ax
	mov ax, 0x0e30
	int 10h
	pop ax
  .dd:
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov ax, 0x0e2f
	int 10h

	mov ax,dx		; separate out year
	shr ax,9
	and ax,0x3F
	add ax,1980
	xor dx, dx
	mov bx, 100
	div bx
	mov ax, dx
	cmp al, 10
	jae .yy
	push ax
	mov ax, 0x0e30
	int 10h
	pop ax
  .yy:
	call os_int_to_string
	mov si, ax
	call os_print_string

	popa
	ret

; type a DOS format (short, 8.3) file name
; based on ASCII-7 file string (no UTF)
; allows a few more characters then PCDOS (ignores control, space, <del> and graphics)
; IN: ES:DI points to name in directory entry
type_name:
	pusha
	mov bx, di
	mov cx, 8
	add bx, cx		; point to extension

  .name_str1:
	mov al, [es:di]
	inc di
	cmp al,' '		; must be between '!' and '~'
	je .q_extend		; <space> is an unused slot
	jle .name_end		; 0 = entry not used, control not allowed
	cmp al,'~'		; no <del>, bit 8 set on delete (should be ASCII-7)
	ja .name_end
	mov ah, 0x0e
	int 10h
	loop .name_str1

  .q_extend:
	mov al,'.'		; output only if valid extension
	cmp byte [es:bx],' '	; space => no extension
	jle .name_end
	mov ah, 0x0e
	int 10h
	mov di, bx
	mov cx,3

  .name_str2:
	mov al, [es:di]
	inc di
	cmp al,' '		; must be between '!' and '~'
	jle .name_end
	cmp al,'~'		; no <del> or above
	ja .name_end
	mov ah, 0x0e
	int 10h
	loop .name_str2

  .name_end:
	popa
	ret


; =====================================================================

exit:
	ret


; =====================================================================

	input			times 64 db 0
	command			times 32 db 0

	dirlist			times 1024 db 0
	tmp_string		times 15 db 0

	file_size		dw 0
	param_list		dw 0

	bin_extension		db '.BIN', 0
	bas_extension		db '.BAS', 0
	pcx_extension		db '.PCX', 0

	prompt			db 'GMUOS> ', 0

	dir_readfail_msg	db 'Unable to read disk directory', 13, 10, 0
	dir_header_1		db 13, 10, '  Filename            Size (B)   |   Filename            Size (B)', 13, 10, 0
	dir_header_2		db '  --------------------------   +   --------------------------', 13, 10, 0
	dir_divider		db '   |   ', 0
	dir_summary_div		db '  -----------------------------------------------------------', 13, 10, 0
	dir_summary_pre		db '  Total: ', 0
	dir_summary_post	db ' file(s) found.', 13, 10, 0
	dir_empty_msg		db '  No files found on disk.', 13, 10, 0
	dir_bytes_unit		db ' B', 0
	dir_file_count		dw 0
	dir_col_state		db 0
	dir_size_buf		times 16 db 0

	help_text		db 'GMU OS 0.1 Commands:', 13, 10
				db '  Files:   DIR, LS, CAT, COPY, REN, DEL, SIZE', 13, 10
				db '  System:  CLS, HELP, ABOUT, VER, TIME, DATE, EXIT', 13, 10
				db '  Launch:  Type a program name (.BIN or .BAS)', 13, 10, 0
	invalid_msg		db 'No such command or program', 13, 10, 0
	nofilename_msg		db 'No filename or not enough filenames', 13, 10, 0
	notfound_msg		db 'File not found', 13, 10, 0
	writefail_msg		db 'Could not write file. Write protected or invalid filename?', 13, 10, 0
	exists_msg		db 'Target file already exists!', 13, 10, 0
	finished_msg		db '>>> Program finished, press any key to continue...', 0

	version_msg		db 'GMU OS ', MIKEOS_VER, 13, 10, 0

	exit_string		db 'EXIT', 0
	help_string		db 'HELP', 0
	cls_string		db 'CLS', 0
	dir_string		db 'DIR', 0
	time_string		db 'TIME', 0
	date_string		db 'DATE', 0
	ver_string		db 'VER', 0
	about_string		db 'ABOUT', 0

	about_text		db 'GMU OS 0.1 -- C-Oriented Learning Derivative', 13, 10
				db 'Base Kernel: MikeOS 4.7.0 (16-bit x86 Real Mode)', 13, 10
				db 'Kernel Load: 0x2000:0000 (Physical 0x20000)', 13, 10
				db 'Course: UE25CS2304 -- Operating System with Practice', 13, 10, 0
	cat_string		db 'CAT', 0
	del_string		db 'DEL', 0
	ren_string		db 'REN', 0
	copy_string		db 'COPY', 0
	size_string		db 'SIZE', 0
	list_string		db 'LS', 0

	kern_file_string	db 'KERNEL', 0
	kern_warn_msg		db 'Cannot execute kernel file!', 13, 10, 0


; ==================================================================

