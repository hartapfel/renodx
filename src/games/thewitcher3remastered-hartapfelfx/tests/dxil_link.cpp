// Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
// Offline assembler/linker for audited native DXIL cloud-term adapters.
#include <windows.h>
#include <dxcapi.h>
#include <wrl/client.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <vector>
using Microsoft::WRL::ComPtr;
void Check(HRESULT result) {
  if (FAILED(result)) throw std::runtime_error("DXIL HRESULT " + std::to_string(result));
}
std::vector<char> Read(const char* path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) throw std::runtime_error(std::string("Missing ") + path);
  return {std::istreambuf_iterator<char>(input), {}};
}
void Result(IDxcOperationResult* operation, IDxcBlob** blob) {
  HRESULT status;
  Check(operation->GetStatus(&status));
  ComPtr<IDxcBlobEncoding> errors;
  operation->GetErrorBuffer(&errors);
  if (errors && errors->GetBufferSize()) std::cerr.write(static_cast<const char*>(errors->GetBufferPointer()), errors->GetBufferSize());
  Check(status);
  Check(operation->GetResult(blob));
}
int main(int argc, char** argv) {
  try {
    const bool validate = argc == 4 && std::string(argv[3]) == "--validate";
    if (argc != 3 && !validate && argc < 6) throw std::runtime_error("Expected assembly output [--validate | helper-library entry target linker-options]");
    HMODULE module = LoadLibraryExW(std::filesystem::absolute("bin/dxcompiler.dll").c_str(), nullptr, LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!module) throw std::runtime_error("Could not load repository DXC");
    const auto create = reinterpret_cast<DxcCreateInstanceProc>(GetProcAddress(module, "DxcCreateInstance"));
    if (!create) throw std::runtime_error("Missing DXC entry point");
    ComPtr<IDxcLibrary> library;
    ComPtr<IDxcAssembler> assembler;
    Check(create(CLSID_DxcLibrary, IID_PPV_ARGS(&library)));
    Check(create(CLSID_DxcAssembler, IID_PPV_ARGS(&assembler)));
    const auto text = Read(argv[1]);
    ComPtr<IDxcBlobEncoding> source;
    Check(library->CreateBlobWithEncodingFromPinned(text.data(), UINT32(text.size()), CP_UTF8, &source));
    ComPtr<IDxcOperationResult> operation;
    Check(assembler->AssembleToContainer(source.Get(), &operation));
    ComPtr<IDxcBlob> binary;
    Result(operation.Get(), &binary);
    if (argc >= 6) {
      ComPtr<IDxcLinker> linker;
      Check(create(CLSID_DxcLinker, IID_PPV_ARGS(&linker)));
      Check(linker->RegisterLibrary(L"native", binary.Get()));
      const auto helper_bytes = Read(argv[3]);
      ComPtr<IDxcBlobEncoding> helper;
      Check(library->CreateBlobWithEncodingFromPinned(helper_bytes.data(), UINT32(helper_bytes.size()), 0, &helper));
      Check(linker->RegisterLibrary(L"clouds", helper.Get()));
      const wchar_t* names[] = {L"native", L"clouds"};
      std::vector<std::wstring> option_text{L"-HV", L"2021"};
      for (int index = 6; index < argc; ++index) option_text.push_back(std::filesystem::path(argv[index]).wstring());
      std::vector<const wchar_t*> arguments;
      for (const auto& option : option_text) arguments.push_back(option.c_str());
      const std::wstring entry = std::filesystem::path(argv[4]).wstring(), target = std::filesystem::path(argv[5]).wstring();
      operation.Reset(); binary.Reset();
      Check(linker->Link(entry == L"-" ? L"" : entry.c_str(), target.c_str(), names, 2, arguments.data(), UINT32(arguments.size()), &operation));
      Result(operation.Get(), &binary);
    }
    if (validate) {
      ComPtr<IDxcValidator> validator;
      Check(create(CLSID_DxcValidator, IID_PPV_ARGS(&validator)));
      operation.Reset();
      Check(validator->Validate(binary.Get(), DxcValidatorFlags_InPlaceEdit, &operation));
      HRESULT status;
      Check(operation->GetStatus(&status));
      ComPtr<IDxcBlobEncoding> errors;
      operation->GetErrorBuffer(&errors);
      if (errors && errors->GetBufferSize()) std::cerr.write(static_cast<const char*>(errors->GetBufferPointer()), errors->GetBufferSize());
      Check(status);
    }
    std::ofstream output(argv[2], std::ios::binary);
    output.write(static_cast<const char*>(binary->GetBufferPointer()), binary->GetBufferSize());
    if (!output) throw std::runtime_error("Could not write linked shader");
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
