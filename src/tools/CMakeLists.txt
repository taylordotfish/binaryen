function(binaryen_add_executable name sources)
  add_executable(${name} ${sources})
  target_link_libraries(${name} ${CMAKE_THREAD_LIBS_INIT})
  target_link_libraries(${name} binaryen)
  set_property(TARGET ${name} PROPERTY CXX_STANDARD ${CXX_STANDARD})
  set_property(TARGET ${name} PROPERTY CXX_STANDARD_REQUIRED ON)
  binaryen_setup_rpath(${name})
  install(TARGETS ${name} DESTINATION ${CMAKE_INSTALL_BINDIR})
endfunction()

include_directories(fuzzing)
FILE(GLOB fuzzing_HEADERS fuzzing/*h)
set(fuzzing_SOURCES
  fuzzing/fuzzing.cpp
  fuzzing/random.cpp
  ${fuzzing_HEADERS}
)

binaryen_add_executable(wasm-opt "${fuzzing_SOURCES};wasm-opt.cpp")
binaryen_add_executable(wasm-shell wasm-shell.cpp)
binaryen_add_executable(wasm-metadce wasm-metadce.cpp)
binaryen_add_executable(wasm2js wasm2js.cpp)
binaryen_add_executable(wasm-emscripten-finalize wasm-emscripten-finalize.cpp)
binaryen_add_executable(wasm-as wasm-as.cpp)
binaryen_add_executable(wasm-dis wasm-dis.cpp)
binaryen_add_executable(wasm-ctor-eval wasm-ctor-eval.cpp)
binaryen_add_executable(wasm-reduce wasm-reduce.cpp)

add_subdirectory(wasm-split)
