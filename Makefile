	
AS = riscv64-unknown-linux-musl-as
LD = riscv64-unknown-linux-musl-ld
SRC_DIR = src
BUILD_DIR = build
OUTPUT_NAME = $(notdir $(CURDIR))
OBJS = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(wildcard $(SRC_DIR)/*.s))
OUTPUT = $(BUILD_DIR)/$(OUTPUT_NAME)

# Ensure build directory exists
$(shell mkdir -p $(BUILD_DIR))

all: $(OUTPUT)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	$(AS) -o $@ $<

$(OUTPUT): $(OBJS)
	$(LD) -o $@ $^

send:
	make
	scp -O $(OUTPUT) root@milkv:

clean:
	rm -rf $(BUILD_DIR)
