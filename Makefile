PLATFORM := macos_x64
#PLATFORM := linux-x64

GRPC_CLIENT_DIR := client/csharp-unity/Assets/GRPC
GRPC_CLIENT_GENERATED_DIR := $(GRPC_CLIENT_DIR)/Pj.Grpc.Sample

GRPC_SERVER_GENERATED_DIR := server/python
GRPC_PROTOC_DIR := grpc-protoc

# https://packages.grpc.io/archive/2018/11/e0d9692fa30cf3a7a8410a722693d5d3d68fb0fd-6619311d-4470-4a1a-b68e-b84bacb2e22c/index.xml

GRPC_BUILD_YEAR := 2018
GRPC_BUILD_MONTH := 11
GRPC_BUILD_COMMIT := e0d9692fa30cf3a7a8410a722693d5d3d68fb0fd-6619311d-4470-4a1a-b68e-b84bacb2e22c
GRPC_BUILD_VERSION := 1.18.0-dev

GRPC_PROTOC := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz
GRPC_PYTHON := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/python
GRPC_CSHARP_UNITY := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/csharp/grpc_unity_package.$(GRPC_BUILD_VERSION).zip
GRPC_PROTOC_PLUGINS := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz

dep: grpc-protoc-plugins	grpc-unity-package

init-grpc-protoc-plugins:
	mkdir -p $(GRPC_PROTOC_DIR)

init-client:
	mkdir -p $(GRPC_CLIENT_GENERATED_DIR)

init:	init-client	init-grpc-tools

build-server:	protoc-server

build-client:	protoc-client

run-server:
	cd $(GRPC_SERVER_GENERATED_DIR) && python server.py

run-client:
	@echo "TODO"

grpc-protoc-plugins:	init-grpc-protoc-plugins
	wget -O grpc-protoc.tar.gz $(GRPC_PROTOC_PLUGINS)
	tar xvfz grpc-protoc.tar.gz -C $(GRPC_PROTOC_DIR)
	chmod +x $(GRPC_PROTOC_DIR)/protoc
	rm grpc-protoc.tar.gz

grpc-unity-package:	init-client
	wget -O grpc_unity_package.zip $(GRPC_CSHARP_UNITY)
	unzip -o grpc_unity_package.zip -d $(GRPC_CLIENT_DIR)
	rm grpc_unity_package.zip

protoc-client:
	$(GRPC_PROTOC_DIR)/protoc -I proto --csharp_out $(GRPC_CLIENT_GENERATED_DIR) --grpc_out $(GRPC_CLIENT_GENERATED_DIR) proto/*.proto --plugin=protoc-gen-grpc=$(GRPC_PROTOC_DIR)/grpc_csharp_plugin

protoc-server:
	$(GRPC_PROTOC_DIR)/protoc -I proto --python_out $(GRPC_SERVER_GENERATED_DIR) --grpc_out $(GRPC_SERVER_GENERATED_DIR) proto/*.proto --plugin=protoc-gen-grpc=$(GRPC_PROTOC_DIR)/grpc_python_plugin

clean-client:
	rm -rf $(GRPC_CLIENT_DIR)

clean-server:
	rm -f $(GRPC_SERVER_GENERATED_DIR)/*_pb2*

clean:	clean-client	clean-server
	rm -rf $(GRPC_PROTOC_DIR)