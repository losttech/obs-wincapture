#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "get-graphics-offsets.h"

struct hook_info *open_hook_info_shmem(const char *shmemName)
{
	HANDLE shmem;
	if (shmemName[0] == '\\') {
		wchar_t wideName[MAX_PATH + 1];
		mbstowcs(wideName, shmemName, MAX_PATH);
		shmem = nt_open_map(wideName);
	} else {
		shmem = OpenFileMappingA(FILE_MAP_WRITE, false, shmemName);
	}

	if (!shmem) {
		return NULL;
	}

	struct hook_info *result = (struct hook_info *)MapViewOfFile(
		shmem, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(struct hook_info));
	if (!result) {
		return NULL;
	}

	return result;
}

int main(int argc, char *argv[])
{
	struct hook_info *hookInfo = calloc(1, sizeof(struct hook_info));

	if (argc == 2) {
		hookInfo = open_hook_info_shmem(argv[1]);
		if (!hookInfo) {
			DWORD error = GetLastError();
			printf("failed to open hook info shared memory");
			return error;
		}
	}

	WNDCLASSA wc = {0};
	wc.style = CS_OWNDC;
	wc.hInstance = GetModuleHandleA(NULL);
	wc.lpfnWndProc = (WNDPROC)DefWindowProcA;
	wc.lpszClassName = DUMMY_WNDCLASS;

	SetErrorMode(SEM_FAILCRITICALERRORS);

	if (!RegisterClassA(&wc)) {
		printf("failed to register '%s'\n", DUMMY_WNDCLASS);
		return -1;
	}

	get_d3d9_offsets(&hookInfo->offsets.d3d9);
	get_d3d8_offsets(&hookInfo->offsets.d3d8);
	get_dxgi_offsets(&hookInfo->offsets.dxgi, &hookInfo->offsets.dxgi2);

	printf("[d3d8]\n");
	printf("present=0x%" PRIx32 "\n", hookInfo->offsets.d3d8.present);
	printf("[d3d9]\n");
	printf("present=0x%" PRIx32 "\n", hookInfo->offsets.d3d9.present);
	printf("present_ex=0x%" PRIx32 "\n", hookInfo->offsets.d3d9.present_ex);
	printf("present_swap=0x%" PRIx32 "\n",
	       hookInfo->offsets.d3d9.present_swap);
	printf("d3d9_clsoff=0x%" PRIx32 "\n",
	       hookInfo->offsets.d3d9.d3d9_clsoff);
	printf("is_d3d9ex_clsoff=0x%" PRIx32 "\n",
	       hookInfo->offsets.d3d9.is_d3d9ex_clsoff);
	printf("[dxgi]\n");
	printf("present=0x%" PRIx32 "\n", hookInfo->offsets.dxgi.present);
	printf("present1=0x%" PRIx32 "\n", hookInfo->offsets.dxgi.present1);
	printf("resize=0x%" PRIx32 "\n", hookInfo->offsets.dxgi.resize);
	printf("release=0x%" PRIx32 "\n", hookInfo->offsets.dxgi2.release);

	(void)argc;
	(void)argv;
	return 0;
}
