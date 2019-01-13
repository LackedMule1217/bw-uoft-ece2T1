`timescale 1ns / 1ns // `timescale time_unit/time_precision

module hexDecoder(SW, HEX0);

	// assign io
	input [3:0] SW;
	output [6:0] HEX0;
	
	// assign output
	assign HEX0[0] = ((!SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (!SW[1]) & (SW[2]) & (SW[3])) | 
						  ((SW[0]) & (SW[1]) & (!SW[2]) & (SW[3]));
						  
	assign HEX0[1] = ((!SW[0]) & (SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (!SW[1]) & (SW[2]) & (SW[3])) | 
						  ((SW[0]) & (SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (SW[2]) & (SW[3]));
						  
	assign HEX0[2] = ((!SW[0]) & (!SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (SW[2]) & (SW[3]));
						  
	assign HEX0[3] = ((!SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (SW[2]) & (SW[3])) | 
						  ((SW[0]) & (!SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((SW[0]) & (SW[1]) & (SW[2]) & (SW[3]));
						  
	assign HEX0[4] = ((!SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (!SW[1]) & (SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (SW[2]) & (SW[3])) | 
						  ((SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3]));
						  
	assign HEX0[5] = ((!SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (!SW[1]) & (SW[2]) & (!SW[3])) | 
						  ((!SW[0]) & (!SW[1]) & (SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (SW[2]) & (SW[3])) | 
						  ((SW[0]) & (SW[1]) & (!SW[2]) & (SW[3]));

	assign HEX0[6] = ((!SW[0]) & (!SW[1]) & (!SW[2]) & (!SW[3])) | 
						  ((!SW[0]) & (!SW[1]) & (!SW[2]) & (SW[3])) | 
						  ((!SW[0]) & (SW[1]) & (SW[2]) & (SW[3]));
	
endmodule