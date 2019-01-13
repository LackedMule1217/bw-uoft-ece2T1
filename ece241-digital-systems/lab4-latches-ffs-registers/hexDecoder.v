`timescale 1ns / 1ns // `timescale time_unit/time_precision

module hexDecoder(signal, hex);

	// assign io
	input [3:0] signal;
	output [6:0] hex;
	
	// assign output
	assign hex[0] = ((!signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (!signal[1]) & (signal[2]) & (signal[3])) | 
						  ((signal[0]) & (signal[1]) & (!signal[2]) & (signal[3]));
						  
	assign hex[1] = ((!signal[0]) & (signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (!signal[1]) & (signal[2]) & (signal[3])) | 
						  ((signal[0]) & (signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (signal[2]) & (signal[3]));
						  
	assign hex[2] = ((!signal[0]) & (!signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (signal[2]) & (signal[3]));
						  
	assign hex[3] = ((!signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (signal[2]) & (signal[3])) | 
						  ((signal[0]) & (!signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((signal[0]) & (signal[1]) & (signal[2]) & (signal[3]));
						  
	assign hex[4] = ((!signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (!signal[1]) & (signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (signal[2]) & (signal[3])) | 
						  ((signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3]));
						  
	assign hex[5] = ((!signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (!signal[1]) & (signal[2]) & (!signal[3])) | 
						  ((!signal[0]) & (!signal[1]) & (signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (signal[2]) & (signal[3])) | 
						  ((signal[0]) & (signal[1]) & (!signal[2]) & (signal[3]));

	assign hex[6] = ((!signal[0]) & (!signal[1]) & (!signal[2]) & (!signal[3])) | 
						  ((!signal[0]) & (!signal[1]) & (!signal[2]) & (signal[3])) | 
						  ((!signal[0]) & (signal[1]) & (signal[2]) & (signal[3]));
	
endmodule