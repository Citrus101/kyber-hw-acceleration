CC ?= /usr/bin/cc
CFLAGS += -Wall -Wextra -Wpedantic -Wmissing-prototypes -Wredundant-decls \
  -Wshadow -Wpointer-arith -O3 -fomit-frame-pointer -z noexecstack
NISTFLAGS += -Wno-unused-result -O3 -fomit-frame-pointer
RM = /bin/rm

SOURCES = kem.c indcpa.c polyvec.c poly.c ntt.c cbd.c reduce.c verify.c 
SOURCESKECCAK = $(SOURCES) fips202.c symmetric-shake.c
HEADERS = params.h kem.h indcpa.h polyvec.h poly.h ntt.h cbd.h reduce.c verify.h symmetric.h
HEADERSKECCAK = $(HEADERS) fips202.h

.PHONY: all speed shared clean

all: test speed shared nistkat

test: \
  test/test_kyber512 \
  test/test_kyber768 \
  test/test_kyber1024 \
  test/test_vectors512 \
  test/test_vectors768 \
  test/test_vectors1024 \

speed: \
  test/test_speed512 \
  test/test_speed768 \
  test/test_speed1024 \

shared: \
  lib/libpqcrystals_kyber512_ref.so \
  lib/libpqcrystals_kyber768_ref.so \
  lib/libpqcrystals_kyber1024_ref.so \
  lib/libpqcrystals_fips202_ref.so \

nistkat: \
	nistkat/PQCgenKAT_kem512 \
	nistkat/PQCgenKAT_kem768 \
	nistkat/PQCgenKAT_kem1024 \


lib/libpqcrystals_fips202_ref.so: fips202.c fips202.h
	mkdir -p lib
	$(CC) -shared -fPIC $(CFLAGS) fips202.c -o $@

lib/libpqcrystals_kyber512_ref.so: $(SOURCES) $(HEADERS) symmetric-shake.c
	mkdir -p lib
	$(CC) -shared -fPIC $(CFLAGS) -DKYBER_K=2 $(SOURCES) symmetric-shake.c -o $@

lib/libpqcrystals_kyber768_ref.so: $(SOURCES) $(HEADERS) symmetric-shake.c
	mkdir -p lib
	$(CC) -shared -fPIC $(CFLAGS) -DKYBER_K=3 $(SOURCES) symmetric-shake.c -o $@

lib/libpqcrystals_kyber1024_ref.so: $(SOURCES) $(HEADERS) symmetric-shake.c
	mkdir -p lib
	$(CC) -shared -fPIC $(CFLAGS) -DKYBER_K=4 $(SOURCES) symmetric-shake.c -o $@

test/test_kyber512: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_kyber.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=2 $(SOURCESKECCAK) randombytes.c test/test_kyber.c -o $@

test/test_kyber768: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_kyber.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=3 $(SOURCESKECCAK) randombytes.c test/test_kyber.c -o $@

test/test_kyber1024: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_kyber.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=4 $(SOURCESKECCAK) randombytes.c test/test_kyber.c -o $@

test/test_vectors512: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_vectors.c
	$(CC) $(CFLAGS) -DKYBER_K=2 $(SOURCESKECCAK) test/test_vectors.c -o $@

test/test_vectors768: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_vectors.c
	$(CC) $(CFLAGS) -DKYBER_K=3 $(SOURCESKECCAK) test/test_vectors.c -o $@

test/test_vectors1024: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_vectors.c
	$(CC) $(CFLAGS) -DKYBER_K=4 $(SOURCESKECCAK) test/test_vectors.c -o $@

test/test_speed512: $(SOURCESKECCAK) $(HEADERSKECCAK) test/cpucycles.h test/cpucycles.c test/speed_print.h test/speed_print.c test/test_speed.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=2 $(SOURCESKECCAK) randombytes.c test/cpucycles.c test/speed_print.c test/test_speed.c -o $@

test/test_speed768: $(SOURCESKECCAK) $(HEADERSKECCAK) test/cpucycles.h test/cpucycles.c test/speed_print.h test/speed_print.c test/test_speed.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=3 $(SOURCESKECCAK) randombytes.c test/cpucycles.c test/speed_print.c test/test_speed.c -o $@

test/test_speed1024: $(SOURCESKECCAK) $(HEADERSKECCAK) test/cpucycles.h test/cpucycles.c test/speed_print.h test/speed_print.c test/test_speed.c randombytes.c
	$(CC) $(CFLAGS) -DKYBER_K=4 $(SOURCESKECCAK) randombytes.c test/cpucycles.c test/speed_print.c test/test_speed.c -o $@

nistkat/PQCgenKAT_kem512: $(SOURCESKECCAK) $(HEADERSKECCAK) nistkat/PQCgenKAT_kem.c nistkat/rng.c nistkat/rng.h
	$(CC) $(NISTFLAGS) -DKYBER_K=2 -o $@ $(SOURCESKECCAK) nistkat/rng.c nistkat/PQCgenKAT_kem.c $(LDFLAGS) -lcrypto

nistkat/PQCgenKAT_kem768: $(SOURCESKECCAK) $(HEADERSKECCAK) nistkat/PQCgenKAT_kem.c nistkat/rng.c nistkat/rng.h
	$(CC) $(NISTFLAGS) -DKYBER_K=3 -o $@ $(SOURCESKECCAK) nistkat/rng.c nistkat/PQCgenKAT_kem.c $(LDFLAGS) -lcrypto

nistkat/PQCgenKAT_kem1024: $(SOURCESKECCAK) $(HEADERSKECCAK) nistkat/PQCgenKAT_kem.c nistkat/rng.c nistkat/rng.h
	$(CC) $(NISTFLAGS) -DKYBER_K=4 -o $@ $(SOURCESKECCAK) nistkat/rng.c nistkat/PQCgenKAT_kem.c $(LDFLAGS) -lcrypto

VERILATOR = verilator
TOP       = ntt_full

# Paths
HW_DIR = ../hw
HW_NTT_DIR = $(HW_DIR)/ntt
SW_DIR = .
TEST_DIR = ./test

# RTL sources
RTL_SRCS = \
    $(HW_NTT_DIR)/ntt_full.v \
    $(HW_NTT_DIR)/ntt_controller.v \
    $(HW_NTT_DIR)/ntt_ram.v \
    $(HW_NTT_DIR)/ntt_bfu.v \
    $(HW_NTT_DIR)/zetas_rom.v

# $(SW_DIR)/my_sign_verify.c \
# Software sources
SW_SRCS = \
    $(SW_DIR)/poly.c \
    $(SW_DIR)/polyvec.c \
    $(SW_DIR)/ntt.c \
    $(SW_DIR)/reduce.c \
    $(SW_DIR)/fips202.c \
    $(SW_DIR)/symmetric-shake.c \
    $(SW_DIR)/randombytes.c 

# Headers
# INCLUDES = -I$(SW_DIR) -I$(HW_DIR)
INCLUDES = -I. -I.. -I../../hw/ntt

obj_dir/V$(TOP): $(RTL_SRCS) $(SOURCESKECCAK)
	$(VERILATOR) --cc $(RTL_SRCS) \
		--exe $(SOURCESKECCAK) test/tb_ntt_full.cpp randombytes.c \
		--top-module $(TOP) \
		-CFLAGS "$(INCLUDES) -DNTT_HW" \
		-LDFLAGS "-lm"

ntt: obj_dir/V$(TOP)
	make -C ./obj_dir -f V$(TOP).mk
		
ntt_run: ntt 

obj_dir/Vntt_bfu: $(RTL_SRCS) $(SOURCESKECCAK)
	$(VERILATOR) --cc $(RTL_SRCS) \
		--exe $(SOURCESKECCAK) test/tb_ntt_bfu.cpp randombytes.c \
		--top-module ntt_bfu \
		-CFLAGS "$(INCLUDES)" \
		-LDFLAGS "-lm"

bfu: obj_dir/Vntt_bfu
	make -C ./obj_dir -f Vntt_bfu.mk

bfu_run: bfu
# ######################################################################
# Dilithium hardware build (NTT)
# ######################################################################

NTT_TOP    = ntt_full
OBJ_NTT    = obj_dir_dil_ntt

NTT_RTL_SRCS = \
    ../hw/ntt/ntt_full.v \
    ../hw/ntt/ntt_controller.v \
    ../hw/ntt/ntt_ram.v \
    ../hw/ntt/ntt_bfu.v \
    ../hw/ntt/zetas_rom.v

SW_SRCS = \
    $(SOURCESKECCAK) \
    randombytes.c \
    $(TEST_DIR)/tb_ntt_full.cpp 


$(OBJ_NTT)/V$(NTT_TOP)_: $(NTT_RTL_SRCS) $(SW_SRCS)
	echo "nice"
	$(VERILATOR) --cc $(NTT_RTL_SRCS) \
		--exe $(SW_SRCS) \
		--top-module $(NTT_TOP) \
		--Mdir $(OBJ_NTT) \
		-CFLAGS "$(INCLUDES)" \
		-LDFLAGS "-lm"
	make -C $(OBJ_NTT) -f V$(NTT_TOP).mk


run_ntt_hw: $(OBJ_NTT)/V$(NTT_TOP)_
	./$(OBJ_NTT)/V$(NTT_TOP)

# # ######################################################################
# # # Combined Dilithium hardware build (NTT + Keccak)
# # ######################################################################

# KYB_NTT_TOP    = ntt_full
# KYB_INTT_TOP    = intt_full
# KYB_KECCAK_TOP = keccak_f1600
# KYB_OBJ_NTT    = obj_dir_dil_ntt
# KYB_OBJ_INTT    = obj_dir_dil_intt
# KYB_OBJ_KECCAK = obj_dir_dil_keccak

# KYB_NTT_RTL_SRCS = \
#     ../hw/ntt/ntt_full.v \
#     ../hw/ntt/ntt_controller.v \
#     ../hw/ntt/ntt_ram.v \
#     ../hw/ntt/ntt_bfu.v \
#     ../hw/ntt/zetas_rom.v

# KYB_INTT_RTL_SRCS = \
#     ../hw/intt/intt_full.v \
#     ../hw/intt/intt_controller.v \
#     ../hw/intt/ntt_ram.v \
#     ../hw/intt/intt_bfu.v \
#     ../hw/intt/zetas_rom.v

# KYB_KECCAK_RTL_SRCS = \
#     ../hw/hash/keccak-hw/pkg_keccak.sv \
#     ../hw/hash/keccak_f1600.sv \
#     ../hw/hash/keccak-hw/keccak_round.sv \
#     ../hw/hash/keccak-hw/keccak_round_constants_gen.sv

# KYB_HW_SW_SRCS = \
#     my_sign_verify.c \
#     sign.c \
#     packing.c \
#     poly.c \
#     polyvec.c \
#     ntt.c \
#     reduce.c \
#     rounding.c \
#     fips202.c \
#     symmetric-shake.c \
#     randombytes.c \
#     ntt_hw_verilator.cpp \
#     keccak_hw_verilator.cpp

# KYB_HW_INCLUDES = -I. -I../hw/ntt -I../hw/hash -I../hw/hash/keccak-hw

# $(KYB_OBJ_KECCAK)/V$(KYB_KECCAK_TOP)__ALL.a: $(KYB_KECCAK_RTL_SRCS)
# 	$(VERILATOR) --cc $(KYB_KECCAK_RTL_SRCS) \
# 		--top-module $(KYB_KECCAK_TOP) \
# 		--Mdir $(KYB_OBJ_KECCAK)
# 	make -C $(KYB_OBJ_KECCAK) -f V$(KYB_KECCAK_TOP).mk V$(KYB_KECCAK_TOP)__ALL.a

# $(KYB_OBJ_NTT)/V$(KYB_NTT_TOP)_: $(KYB_NTT_RTL_SRCS) $(KYB_HW_SW_SRCS) $(KYB_OBJ_KECCAK)/V$(KYB_KECCAK_TOP)__ALL.a
# 	$(VERILATOR) --cc $(KYB_NTT_RTL_SRCS) \
# 		--exe $(KYB_HW_SW_SRCS) \
# 		--top-module $(KYB_NTT_TOP) \
# 		--Mdir $(KYB_OBJ_NTT) \
# 		-CFLAGS "$(KYB_HW_INCLUDES) -I$(abspath $(KYB_OBJ_KECCAK)) -O2 -DNTT_HW -DKECCAK_HW" \
# 		-LDFLAGS "-lm $(abspath $(KYB_OBJ_KECCAK))/V$(KYB_KECCAK_TOP)__ALL.a"
# 	make -C $(KYB_OBJ_NTT) -f V$(KYB_NTT_TOP).mk

# dilithium_hw: $(KYB_OBJ_NTT)/V$(KYB_NTT_TOP)_

# run_dilithium_hw: dilithium_hw
# 	./$(KYB_OBJ_NTT)/V$(KYB_NTT_TOP)

# ######################################################################
# # Combined Dilithium hardware build (NTT + INTT + Keccak)
# ######################################################################

# KYB_HW_SW_SRCS_COMBINED = \
#     my_sign_verify.c \
#     sign.c \
#     packing.c \
#     poly.c \
#     polyvec.c \
#     ntt.c \
#     reduce.c \
#     rounding.c \
#     fips202.c \
#     symmetric-shake.c \
#     randombytes.c \
#     ntt_hw_verilator.cpp \
#     keccak_hw_verilator.cpp \
#     intt_hw_verilator.cpp \

# KYB_HW_INCLUDES_COMBINED = -I. -I../hw/intt -I../hw/ntt -I../hw/hash -I../hw/hash/keccak-hw

# # $(KYB_OBJ_KECCAK)/V$(KYB_KECCAK_TOP)__ALL.a: $(KYB_KECCAK_RTL_SRCS)
# # 	$(VERILATOR) --cc $(KYB_KECCAK_RTL_SRCS) \
# # 		--top-module $(KYB_KECCAK_TOP) \
# # 		--Mdir $(KYB_OBJ_KECCAK) 
# # 	make -C $(KYB_OBJ_KECCAK) -f V$(KYB_KECCAK_TOP).mk V$(KYB_KECCAK_TOP)__ALL.a

# $(KYB_OBJ_INTT)/V$(KYB_INTT_TOP)__ALL.a: $(KYB_INTT_RTL_SRCS)
# 	$(VERILATOR) --cc $(KYB_INTT_RTL_SRCS) \
# 		--top-module $(KYB_INTT_TOP) \
# 		--Mdir $(KYB_OBJ_INTT) 
# 	make -C $(KYB_OBJ_INTT) -f V$(KYB_INTT_TOP).mk V$(KYB_INTT_TOP)__ALL.a

# $(KYB_OBJ_NTT)/V$(KYB_NTT_TOP): $(KYB_NTT_RTL_SRCS) $(KYB_HW_SW_SRCS_COMBINED)  
# 	$(VERILATOR) --cc $(KYB_NTT_RTL_SRCS) \
# 		--exe $(KYB_HW_SW_SRCS_COMBINED) \
# 		--top-module $(KYB_NTT_TOP) \
# 		--Mdir $(KYB_OBJ_NTT) \
# 		-CFLAGS "$(KYB_HW_INCLUDES_COMBINED) -I$(abspath $(KYB_OBJ_KECCAK)) -I$(abspath $(KYB_OBJ_INTT)) -O2 -DNTT_HW -DINTT_HW -DKECCAK_HW" \
# 		-LDFLAGS "-lm $(abspath $(KYB_OBJ_INTT))/V$(KYB_INTT_TOP)__ALL.a $(abspath $(KYB_OBJ_KECCAK))/V$(KYB_KECCAK_TOP)__ALL.a" 
# 	make -C $(KYB_OBJ_NTT) -f V$(KYB_NTT_TOP).mk

# dilithium_hw_final: $(KYB_OBJ_KECCAK)/V$(KYB_KECCAK_TOP)__ALL.a $(KYB_OBJ_INTT)/V$(KYB_INTT_TOP)__ALL.a $(KYB_OBJ_NTT)/V$(KYB_NTT_TOP) 

# run_dilithium_hw_final: dilithium_hw_final
# 	./$(KYB_OBJ_NTT)/V$(KYB_NTT_TOP)

# ######################################################################
# # Keccak hardware build (mirrors NTT build)
# ######################################################################

# KECCAK_HW_DIR = ../hw/hash
# KECCAK_TOP    = keccak_f1600

# # Keccak RTL sources
# KECCAK_RTL_SRCS = \
#     $(KECCAK_HW_DIR)/keccak-hw/pkg_keccak.sv \
#     $(KECCAK_HW_DIR)/keccak_f1600.sv \
#     $(KECCAK_HW_DIR)/keccak-hw/keccak_round.sv \
#     $(KECCAK_HW_DIR)/keccak-hw/keccak_round_constants_gen.sv

# # Keccak SW sources
# KECCAK_SW_SRCS = \
#     $(SW_DIR)/fips202.c \
#     $(SW_DIR)/keccak_hw_verilator.cpp \
#     ../hw/hash/tb_keccak_f1600.cpp

# # Headers
# KECCAK_INCLUDES = -I$(SW_DIR) -I$(KECCAK_HW_DIR)

# obj_dir/V$(KECCAK_TOP): $(KECCAK_RTL_SRCS) $(KECCAK_SW_SRCS)
# 	$(VERILATOR) --cc $(KECCAK_RTL_SRCS) \
# 		--exe $(KECCAK_SW_SRCS) \
# 		--top-module $(KECCAK_TOP) \
# 		-CFLAGS "$(KECCAK_INCLUDES) -O2 -DKECCAK_HW" \
# 		-LDFLAGS "-lm"
# 	make -C obj_dir -f V$(KECCAK_TOP).mk

# keccak_hw: obj_dir/V$(KECCAK_TOP)

# keccak_hw_run: keccak_hw
# 	./obj_dir/V$(KECCAK_TOP)

test/ntt_test: $(SOURCESKECCAK) $(HEADERSKECCAK) test/test_ntt.c
	$(CC) $(CFLAGS) $(SOURCESKECCAK) test/test_ntt.c randombytes.c -I. -o test/ntt_test

clean:
	rm -rf obj_dir $(KYB_OBJ_NTT) $(KYB_OBJ_INTT) $(KYB_OBJ_KECCAK)
	-$(RM) -f *.gcno *.gcda *.lcov *.o *.so
	-$(RM) -f test/test_kyber512
	-$(RM) -f test/test_kyber768
	-$(RM) -f test/test_kyber1024
	-$(RM) -f test/test_vectors512
	-$(RM) -f test/test_vectors768
	-$(RM) -f test/test_vectors1024
	-$(RM) -f test/test_speed512
	-$(RM) -f test/test_speed768
	-$(RM) -f test/test_speed1024
	-$(RM) -f nistkat/PQCgenKAT_kem512
	-$(RM) -f nistkat/PQCgenKAT_kem768
	-$(RM) -f nistkat/PQCgenKAT_kem1024
	-$(RM) -f nistkat/*.req
	-$(RM) -f nistkat/*.rsp
	-$(RM) -rf lib/
	-$(RM) test/ntt_test
