
; BCRYPT.DLL structures and constants

; Padding / modes (см. bcrypt.h)
BCRYPT_PAD_NONE    = 00000001h
BCRYPT_PAD_PKCS1   = 00000002h
BCRYPT_PAD_OAEP    = 00000004h
BCRYPT_PAD_PSS     = 00000008h

; Chaining modes (BCRYPT_CHAINING_MODE property values are strings; здесь — флаги/идентификаторы, но чаще используют строки)
; (обычно задаются через BCryptSetProperty с текстовыми значениями "ChainingModeCBC", "ChainingModeECB", ...)
BCRYPT_CHAIN_MODE_CBC      = 1
BCRYPT_CHAIN_MODE_ECB      = 2
BCRYPT_CHAIN_MODE_CFB      = 3
BCRYPT_CHAIN_MODE_CCM      = 4
BCRYPT_CHAIN_MODE_GCM      = 5
; (Примечание: реальные именованные значения передаются строками в BCryptSetProperty/BCryptGetProperty). :contentReference[oaicite:1]{index=1}

; Property identifiers (именованные строки — используют в BCryptGetProperty/SetProperty)
BCRYPT_ALGORITHM_NAME      db "AlgorithmName", 0
BCRYPT_OBJECT_LENGTH       db "ObjectLength", 0
BCRYPT_AUTH_TAG_LENGTH     db "AuthTagLength", 0
BCRYPT_BLOCK_LENGTH        db "BlockLength", 0
BCRYPT_KEY_LENGTH          db "KeyLength", 0
BCRYPT_KEY_STRENGTH        db "KeyStength", 0
BCRYPT_HASH_LENGTH         db "HashDigestLength", 0
BCRYPT_OID_LIST            db "OID", 0
; (см. полный список свойств в документации CNG). :contentReference[oaicite:2]{index=2}

; Algorithm identifiers (строки, примеры — чаще используют как LPCWSTR)
BCRYPT_RSA_ALGORITHM       db "RSA", 0
BCRYPT_AES_ALGORITHM       db "AES", 0
BCRYPT_DES_ALGORITHM       db "DES", 0
BCRYPT_3DES_ALGORITHM      db "3DES", 0
BCRYPT_RC4_ALGORITHM       db "RC4", 0
BCRYPT_SHA1_ALGORITHM      db "SHA1", 0
BCRYPT_SHA256_ALGORITHM    db "SHA256", 0
BCRYPT_SHA384_ALGORITHM    db "SHA384", 0
BCRYPT_SHA512_ALGORITHM    db "SHA512", 0
; (полный набор — в CNG Algorithm Identifiers). :contentReference[oaicite:3]{index=3}

; Blob types (имена blob'ов для экспорта/импорта ключей)
BCRYPT_RSAPUBLIC_BLOB      db "RSAPUBLICBLOB", 0
BCRYPT_RSAPRIVATE_BLOB     db "RSAPRIVATEBLOB", 0
BCRYPT_RSAPRIVATE_BLOB_LEGACY db "RSAPRIVATEBLOB_LEGACY", 0
BCRYPT_PRIVATE_KEY_BLOB    db "PRIVATEKEYBLOB", 0
BCRYPT_OPAQUE_KEY_BLOB     db "OPAQUEKEYBLOB", 0
BCRYPT_KEY_DATA_BLOB       db "KEYDATA", 0

; Common flags (вызовы работы с провайдером/ключами)
BCRYPT_PAD_PKCS1_FLAG     = BCRYPT_PAD_PKCS1
BCRYPT_PAD_OAEP_FLAG      = BCRYPT_PAD_OAEP
BCRYPT_PAD_PSS_FLAG       = BCRYPT_PAD_PSS

; Status success (NTSTATUS)
STATUS_SUCCESS            = 000000000h
; (в CNG все возвращаемые значения — NTSTATUS; проверяйте через STATUS_SUCCESS). :contentReference[oaicite:4]{index=4}

; Basic structures (FASM style — только если нужно; в большинстве случаев CNG использует указатели/буферы)
struct BCRYPT_PKCS1_PADDING_INFO
  pszAlgId dq ?    ; LPCWSTR (указатель на строку алгоритма)
ends

struct BCRYPT_OAEP_PADDING_INFO
  pszAlgId dq ?
  pbLabel  dq ?    ; PUCHAR (указатель на label)
  cbLabel  dd ?
ends

struct BCRYPT_PSS_PADDING_INFO
  pszAlgId dq ?
  cbSalt   dd ?
ends
