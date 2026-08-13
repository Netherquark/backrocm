	.text
	.amdgcn_target "amdgcn-amd-amdhsa--gfx90c"
	.amdhsa_code_object_version 6
	.section	.text._Z20vector_square_kernelIfEvPT_PKS0_y,"axG",@progbits,_Z20vector_square_kernelIfEvPT_PKS0_y,comdat
	.protected	_Z20vector_square_kernelIfEvPT_PKS0_y ; -- Begin function _Z20vector_square_kernelIfEvPT_PKS0_y
	.globl	_Z20vector_square_kernelIfEvPT_PKS0_y
	.p2align	8
	.type	_Z20vector_square_kernelIfEvPT_PKS0_y,@function
_Z20vector_square_kernelIfEvPT_PKS0_y:  ; @_Z20vector_square_kernelIfEvPT_PKS0_y
; %bb.0:
	s_load_dword s0, s[4:5], 0x24
	s_load_dwordx2 s[8:9], s[4:5], 0x10
	s_add_u32 s10, s4, 24
	s_addc_u32 s11, s5, 0
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s12, s0, 0xffff
	s_mul_i32 s6, s6, s12
	v_add_u32_e32 v0, s6, v0
	v_cmp_gt_u64_e32 vcc, s[8:9], v[0:1]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_3
; %bb.1:
	s_load_dword s13, s[10:11], 0x0
	s_load_dwordx4 s[0:3], s[4:5], 0x0
	s_mov_b32 s5, 0
	v_lshlrev_b64 v[2:3], 2, v[0:1]
	s_mov_b64 s[6:7], 0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s4, s13, s12
	s_lshl_b64 s[10:11], s[4:5], 2
	v_mov_b32_e32 v4, s3
	v_mov_b32_e32 v5, s1
	v_mov_b32_e32 v6, s5
	v_mov_b32_e32 v7, s11
.LBB0_2:                                ; =>This Inner Loop Header: Depth=1
	v_add_co_u32_e32 v8, vcc, s2, v2
	v_addc_co_u32_e32 v9, vcc, v4, v3, vcc
	global_load_dword v10, v[8:9], off
	v_add_co_u32_e32 v8, vcc, s0, v2
	v_addc_co_u32_e32 v9, vcc, v5, v3, vcc
	v_add_co_u32_e32 v0, vcc, s4, v0
	v_addc_co_u32_e32 v1, vcc, v1, v6, vcc
	v_add_co_u32_e32 v2, vcc, s10, v2
	v_addc_co_u32_e32 v3, vcc, v3, v7, vcc
	v_cmp_le_u64_e32 vcc, s[8:9], v[0:1]
	s_or_b64 s[6:7], vcc, s[6:7]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v10, v10, v10
	global_store_dword v[8:9], v10, off
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execnz .LBB0_2
.LBB0_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z20vector_square_kernelIfEvPT_PKS0_y
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 6
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 11
		.amdhsa_next_free_sgpr 14
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_flat_scratch 0
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._Z20vector_square_kernelIfEvPT_PKS0_y,"axG",@progbits,_Z20vector_square_kernelIfEvPT_PKS0_y,comdat
.Lfunc_end0:
	.size	_Z20vector_square_kernelIfEvPT_PKS0_y, .Lfunc_end0-_Z20vector_square_kernelIfEvPT_PKS0_y
                                        ; -- End function
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 196
; NumSgprs: 18
; NumVgprs: 11
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 18
; NumVGPRsForWavesPerEU: 11
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 6
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.type	__hip_cuid_f2e243d59542c8e3,@object ; @__hip_cuid_f2e243d59542c8e3
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_f2e243d59542c8e3
__hip_cuid_f2e243d59542c8e3:
	.byte	0                               ; 0x0
	.size	__hip_cuid_f2e243d59542c8e3, 1

	.ident	"clang version 19.0.0git"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_f2e243d59542c8e3
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           8
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           _Z20vector_square_kernelIfEvPT_PKS0_y
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         _Z20vector_square_kernelIfEvPT_PKS0_y.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     11
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa--gfx90c
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
