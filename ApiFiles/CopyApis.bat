@ECHO OFF
REM Copy masm api files to other assemblers that use similar files: Jwasm, HJWwasm & Asmc
copy masmApiCall.api JwasmApiCall.api /y
copy masmApiCall.api HJWasmApiCall.api /y
copy masmApiCall.api HJWasm32ApiCall.api /y
copy masmApiCall.api HJWasm64ApiCall.api /y
copy masmApiCall.api AsmcApiCall.api /y
copy masmApiCall.api nasmApiCall.api /y
copy masmApiCall.api fasmApiCall.api /y
copy masmApiCall.api goasmApiCall.api /y

copy masmApiConst.api JwasmApiConst.api /y
copy masmApiConst.api HJWasmApiConst.api /y
copy masmApiConst.api HJWasm32ApiConst.api /y
copy masmApiConst.api HJWasm64ApiConst.api /y
copy masmApiConst.api AsmcApiConst.api /y
copy masmApiConst.api nasmApiConst.api /y
copy masmApiConst.api fasmApiConst.api /y
copy masmApiConst.api goasmApiConst.api /y

copy masmApiStruct.api JwasmApiStruct.api /y
copy masmApiStruct.api HJWasmApiStruct.api /y
copy masmApiStruct.api HJWasm32ApiStruct.api /y
copy masmApiStruct.api HJWasm64ApiStruct.api /y
copy masmApiStruct.api AsmcApiStruct.api /y
copy masmApiStruct.api nasmApiStruct.api /y
copy masmApiStruct.api fasmApiStruct.api /y
copy masmApiStruct.api goasmApiStruct.api /y

copy masmApiWord.api JwasmApiWord.api /y
copy masmApiWord.api HJWasmApiWord.api /y
copy masmApiWord.api HJWasm32ApiWord.api /y
copy masmApiWord.api HJWasm64ApiWord.api /y
copy masmApiWord.api AsmcApiWord.api /y
copy masmApiWord.api nasmApiWord.api /y
copy masmApiWord.api fasmApiWord.api /y
copy masmApiWord.api goasmApiWord.api /y

copy masmMessage.api JwasmMessage.api /y
copy masmMessage.api HJWasmMessage.api /y
copy masmMessage.api HJWasm32Message.api /y
copy masmMessage.api HJWasm64Message.api /y
copy masmMessage.api AsmcMessage.api /y
copy masmMessage.api nasmMessage.api /y
copy masmMessage.api fasmMessage.api /y
copy masmMessage.api goasmMessage.api /y

copy masmType.api JwasmType.api /y
copy masmType.api HJWasmType.api /y
copy masmType.api HJWasm32Type.api /y
copy masmType.api HJWasm64Type.api /y
copy masmType.api AsmcType.api /y
copy masmType.api nasmType.api /y
copy masmType.api fasmType.api /y

copy masmArray.api JwasmArray.api /y
copy masmArray.api HJWasmArray.api /y
copy masmArray.api HJWasm32Array.api /y
copy masmArray.api HJWasm64Array.api /y
copy masmArray.api AsmcArray.api /y
copy masmArray.api nasmArray.api /y
copy masmArray.api fasmArray.api /y

rem copy masmStdlib.api JwasmStdlib.api /y
rem copy masmStdlib.api HJWasmStdlib.api /y
rem copy masmStdlib.api HJWasm32Stdlib.api /y
rem copy masmStdlib.api HJWasm64Stdlib.api /y
rem copy masmStdlib.api AsmcStdlib.api /y