; RUN: %lli -mtriple=%mcjit_triple -use-mcjit %s > /dev/null

define i32 @foo() {
	ret i32 0
}

define i32 @main() {
	icmp ne i1 true, false		; <i1>:1 [#uses=0]
	zext i1 true to i8		; <i8>:2 [#uses=0]
	zext i1 true to i8		; <i8>:3 [#uses=0]
	zext i1 true to i16		; <i16>:4 [#uses=0]
	zext i1 true to i16		; <i16>:5 [#uses=0]
	zext i1 true to i32		; <i32>:6 [#uses=0]
	zext i1 true to i32		; <i32>:7 [#uses=0]
	zext i1 true to i64		; <i64>:8 [#uses=0]
	zext i1 true to i64		; <i64>:9 [#uses=0]
	uitofp i1 true to float		; <float>:10 [#uses=0]
	uitofp i1 true to double		; <double>:11 [#uses=0]
	icmp ne i8 0, 0		; <i1>:12 [#uses=0]
	icmp ne i8 1, 0		; <i1>:13 [#uses=0]
	bitcast i8 0 to i8		; <i8>:14 [#uses=0]
	bitcast i8 -1 to i8		; <i8>:15 [#uses=0]
	sext i8 4 to i16		; <i16>:16 [#uses=0]
	sext i8 4 to i16		; <i16>:17 [#uses=0]
	sext i8 4 to i64		; <i64>:18 [#uses=0]
	sext i8 4 to i64		; <i64>:19 [#uses=0]
	sitofp i8 4 to float		; <float>:20 [#uses=0]
	sitofp i8 4 to double		; <double>:21 [#uses=0]
	icmp ne i8 0, 0		; <i1>:22 [#uses=0]
	icmp ne i8 1, 0		; <i1>:23 [#uses=0]
	bitcast i8 0 to i8		; <i8>:24 [#uses=0]
	bitcast i8 1 to i8		; <i8>:25 [#uses=0]
	zext i8 4 to i16		; <i16>:26 [#uses=0]
	zext i8 4 to i16		; <i16>:27 [#uses=0]
	zext i8 4 to i64		; <i64>:28 [#uses=0]
	zext i8 4 to i64		; <i64>:29 [#uses=0]
	uitofp i8 0 to float		; <float>:30 [#uses=0]
	uitofp i8 0 to double		; <double>:31 [#uses=0]
	icmp ne i16 1, 0		; <i1>:32 [#uses=0]
	trunc i16 -1 to i8		; <i8>:33 [#uses=0]
	trunc i16 255 to i8		; <i8>:34 [#uses=0]
	bitcast i16 0 to i16		; <i16>:35 [#uses=0]
	bitcast i16 0 to i16		; <i16>:36 [#uses=0]
	sext i16 0 to i64		; <i64>:37 [#uses=0]
	sext i16 0 to i64		; <i64>:38 [#uses=0]
	sitofp i16 0 to float		; <float>:39 [#uses=0]
	sitofp i16 0 to double		; <double>:40 [#uses=0]
	icmp ne i16 1, 0		; <i1>:41 [#uses=0]
	trunc i16 1 to i8		; <i8>:42 [#uses=0]
	trunc i16 255 to i8		; <i8>:43 [#uses=0]
	bitcast i16 0 to i16		; <i16>:44 [#uses=0]
	bitcast i16 0 to i16		; <i16>:45 [#uses=0]
	zext i16 0 to i64		; <i64>:46 [#uses=0]
	zext i16 0 to i64		; <i64>:47 [#uses=0]
	uitofp i16 0 to float		; <float>:48 [#uses=0]
	uitofp i16 0 to double		; <double>:49 [#uses=0]
	icmp ne i32 6, 0		; <i1>:50 [#uses=0]
	trunc i32 -6 to i8		; <i8>:51 [#uses=0]
	trunc i32 6 to i8		; <i8>:52 [#uses=0]
	trunc i32 6 to i16		; <i16>:53 [#uses=0]
	bitcast i32 0 to i32		; <i32>:54 [#uses=0]
	sext i32 0 to i64		; <i64>:55 [#uses=0]
	sext i32 0 to i64		; <i64>:56 [#uses=0]
	sitofp i32 0 to float		; <float>:57 [#uses=0]
	sitofp i32 0 to double		; <double>:58 [#uses=0]
	icmp ne i32 6, 0		; <i1>:59 [#uses=0]
	trunc i32 7 to i8		; <i8>:60 [#uses=0]
	trunc i32 8 to i8		; <i8>:61 [#uses=0]
	trunc i32 9 to i16		; <i16>:62 [#uses=0]
	bitcast i32 10 to i32		; <i32>:63 [#uses=0]
	zext i32 0 to i64		; <i64>:64 [#uses=0]
	zext i32 0 to i64		; <i64>:65 [#uses=0]
	uitofp i32 0 to float		; <float>:66 [#uses=0]
	uitofp i32 0 to double		; <double>:67 [#uses=0]
	icmp ne i64 0, 0		; <i1>:68 [#uses=0]
	trunc i64 0 to i8		; <i8>:69 [#uses=0]
	trunc i64 0 to i8		; <i8>:70 [#uses=0]
	trunc i64 0 to i16		; <i16>:71 [#uses=0]
	trunc i64 0 to i16		; <i16>:72 [#uses=0]
	trunc i64 0 to i32		; <i32>:73 [#uses=0]
	trunc i64 0 to i32		; <i32>:74 [#uses=0]
	bitcast i64 0 to i64		; <i64>:75 [#uses=0]
	bitcast i64 0 to i64		; <i64>:76 [#uses=0]
	sitofp i64 0 to float		; <float>:77 [#uses=0]
	sitofp i64 0 to double		; <double>:78 [#uses=0]
	icmp ne i64 1, 0		; <i1>:79 [#uses=0]
	trunc i64 1 to i8		; <i8>:80 [#uses=0]
	trunc i64 1 to i8		; <i8>:81 [#uses=0]
	trunc i64 1 to i16		; <i16>:82 [#uses=0]
	trunc i64 1 to i16		; <i16>:83 [#uses=0]
	trunc i64 1 to i32		; <i32>:84 [#uses=0]
	trunc i64 1 to i32		; <i32>:85 [#uses=0]
	bitcast i64 1 to i64		; <i64>:86 [#uses=0]
	bitcast i64 1 to i64		; <i64>:87 [#uses=0]
	uitofp i64 1 to float		; <float>:88 [#uses=0]
	uitofp i64 0 to double		; <double>:89 [#uses=0]
	bitcast float 0.000000e+00 to float		; <float>:90 [#uses=0]
	fpext float 0.000000e+00 to double		; <double>:91 [#uses=0]
	fptosi double 0.000000e+00 to i8		; <i8>:92 [#uses=0]
	fptoui double 0.000000e+00 to i8		; <i8>:93 [#uses=0]
	fptosi double 0.000000e+00 to i16		; <i16>:94 [#uses=0]
	fptoui double 0.000000e+00 to i16		; <i16>:95 [#uses=0]
	fptosi double 0.000000e+00 to i32		; <i32>:96 [#uses=0]
	fptoui double 0.000000e+00 to i32		; <i32>:97 [#uses=0]
	fptosi double 0.000000e+00 to i64		; <i64>:98 [#uses=0]
	fptrunc double 0.000000e+00 to float		; <float>:99 [#uses=0]
	bitcast double 0.000000e+00 to double		; <double>:100 [#uses=0]
	ret i32 0
}
