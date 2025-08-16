includelib kernel32.lib
includelib user32.lib
includelib msvcrt.lib
includelib ucrt.lib
includelib vcruntime.lib
includelib legacy_stdio_definitions.lib

threadParameter STRUCT
	arr_ptr dq ?
	sum_ptr dq ?
	arr_num dd ?
	arr_size dd ?
threadParameter ENDS

EXTERN GetTickCount:PROC
EXTERN CreateThread:PROC
EXTERN WaitForSingleObject:PROC
EXTERN CloseHandle:PROC
EXTERN printf:PROC

.data
	array1 dq 10 dup(0) ; array 1 with 10 elements
	array2 dq 10 dup(0) ; array 2 with 10 elements
	sum1 dq 0 ; sum for first array
	sum2 dq 0 ; sum for second array
	total_sum dq 0 ; total sum of both arrays
	thread1 dq ? ; handle for first thread
	thread2 dq ? ; handle for second thread
	thread1_param threadParameter <>
	thread2_param threadParameter <>
	seed dd ?

	arr_fmt db "array: %d ", 0 ; format for printing integers
	value_fmt db "value: %d ", 0 ; format for printing single values
	new_line db 10, 0 ; newline character
	sum_fmt db "sum: %lld", 10, 0 ; format for printing sum
	total_fmt db "total sum: %lld", 10, 0 ; format for printing total sum


.code

public main
ALIGN 16


main proc
	; prolog, set up stack frame
	push rbp
	mov rbp, rsp
	sub rsp, 48 ; shadow space for local variables

	call GetTickCount ; initialize random seed
	mov seed, eax ; store the seed

; 1 . Initialize the array and fill it with random numbers

	; Fill first array with random numbers
	lea rcx, array1 ; pointer to first array
	mov rdx, 10 ; size of the first array
	call fillArray ; fill first array with random numbers

	; print first array
	lea rcx, array1 ; pointer to first array
	mov rdx, 10 ; size of the first array
	mov r9, 1 ; array number for printing
	call printArray ; print first array

	; Fill second array with random numbers
	lea rcx, array2 ; pointer to second array
	mov rdx, 10 ; size of the second array
	mov r9, 2 ; array number for printing
	call fillArray ; fill second array with random numbers

	; print second array
	lea rcx, array2 ; pointer to second array
	mov rdx, 10 ; size of the second array
	call printArray ; print second array

; 2 . Sum tow arrays in tow threads
	lea rax, array1 ; pointer to first array
	mov thread1_param.arr_ptr, rax ; set pointer to first array
	lea rax, sum1 ; pointer to first sum
	mov thread1_param.sum_ptr, rax ; set pointer to first sum
	mov thread1_param.arr_num, 1 ; array number for first thread
	mov thread1_param.arr_size, 10 ; size of the first array

	xor rcx, rcx ; security attributes
	xor rdx, rdx ; stack size (default)
	lea r8, sumArrThread       ; thread function
	lea r9, thread1_param      ; thread parameter
	mov qword ptr [rsp + 32], 0 ; creation flags (default)
	lea rax, thread1 ; pointer to thread handle
	mov qword ptr [rsp + 40], rax ; store threadID
	call CreateThread ; create first thread
	mov thread1, rax ; store thread handle

	lea rax, array2 ; pointer to second array
	mov thread2_param.arr_ptr, rax ; set pointer to second array
	lea rax, sum2 ; pointer to second sum
	mov thread2_param.sum_ptr, rax ; set pointer to second sum
	mov thread2_param.arr_num, 2 ; array number for second thread
	mov thread2_param.arr_size, 10 ; size of the second array

	xor rcx, rcx ; security attributes
	xor rdx, rdx ; stack size (default)
	lea r8, sumArrThread       ; thread function
	lea r9, thread2_param      ; thread parameter
	mov qword ptr [rsp + 32], 0 ; creation flags (default)
	lea rax, thread2 ; pointer to thread handle
	mov qword ptr [rsp + 40], rax ; store threadID
	call CreateThread ; create second thread
	mov thread2, rax ; store thread handle

	; Wait for both threads to finish
	mov rcx, thread1 ; handle of first thread
	mov rdx, 0FFFFFFFFh ; infinite timeout
	call WaitForSingleObject ; wait for first thread to finish

	mov rcx, thread2 ; handle of second thread
	mov rdx, 0FFFFFFFFh ; infinite timeout
	call WaitForSingleObject ; wait for second thread to finish

	mov rcx, thread1 ; close first thread handle
	call CloseHandle ; close first thread handle

	mov rcx, thread2 ; close second thread handle
	call CloseHandle ; close second thread handle

; 3 . Print the result
	mov rax, [sum1]
	add rax, [sum2]
	mov [total_sum], rax

	
	lea rcx, sum_fmt ; print first sum
	mov rdx, [sum1] ; first sum value
	call printf ; print first sum

	lea rcx, sum_fmt ; print second sum
	mov rdx, [sum2] ; second sum value
	call printf ; print second sum

	lea rcx, total_fmt ; format string for total sum
	mov rdx, [total_sum] ; total sum value
	call printf ; print total sum

	; epilog, restore stack pointer
	add rsp, 48
	mov rsp, rbp
	pop rbp

	mov rax, 0 ; return value
	exit:
		; Exit the program
		ret
main endp

getRand proc
	mov eax, seed
	imul eax, 1103515245
	add eax, 12345
	and eax, 7FFFFFFFh ; ensure positive value
	mov seed, eax
	ret
getRand endp

fillArray proc
	push rsi
	push rdi
	push rbx

	mov rsi, rcx ; array pointer
	mov rbx, rdx ; array size
	xor rdi, rdi ; index

	fill_loop:
		cmp rdi, rbx
		jge fill_done

		call getRand
		xor rdx, rdx ; clear rdx
		mov rcx, 10
		div rcx ; rax / rcx get a random number in range 0-9

		mov [rsi + rdi * 8], rdx
		inc rdi
		jmp fill_loop

	fill_done:
		pop rbx
		pop rdi
		pop rsi
		ret
fillArray endp

printArray proc
		push rbx
		push rsi
		push rdi
		push rbp
		sub rsp, 32 ; shadow space for local variables


		mov rsi, rcx ; array pointer
		mov rbx, rdx ; array size
		xor rdi, rdi ; index

		lea rcx, arr_fmt ; format string for printing array
		mov rdx, r9 ; array number (passed in r9)
		call printf ; print the array header
	print_loop:
		cmp rdi, rbx
		jge print_done
		lea rcx, value_fmt ; format string
		mov rdx, [rsi + rdi * 8] ; load value from array
		call printf ; print the value

		inc rdi
		jmp print_loop

	print_done:
		lea rcx, new_line ; print newline
		call printf

		add rsp, 32 ; restore stack pointer
		pop rbp
		pop rdi
		pop rsi
		pop rbx
		ret
printArray endp

sumArrThread proc
	push rsi
	push r10
	push rbx
	push rdi
	
	mov rsi, rcx ; thread parameter pointer
	mov rbx, [rsi].threadParameter.arr_ptr ; array pointer
	mov rdi, [rsi].threadParameter.sum_ptr ; sum pointer
	mov r10d, [rsi].threadParameter.arr_size ; array number

	xor rax, rax ; clear sum
	xor ecx, ecx ; index

	sum_loop:
		cmp ecx, r10d
		jge sum_done
		add rax, [rbx + rcx * 8] ; add value to sum
		inc rcx
		jmp sum_loop

	sum_done:
		mov [rdi], rax ; store the sum in the provided pointer

		; cleanup
		pop rdi
		pop rbx
		pop r10
		pop rsi

		xor rax, rax ; return 0 success
		ret
sumArrThread endp

end