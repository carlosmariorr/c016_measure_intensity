//Start of script
	//Initialization variables
	blacks = getDirectory("Choose the Mask general directory (no slide nor gonad)");
	subsets_directory = getDirectory("Choose the Subset directory with your files");
	sbs_list = getFileList(subsets_directory);
	ints = getDirectory("Choose the Intensities general directory (no slide nor gonad)");
	genotype = getString("Genotype: ", "");
	slide = getString("Slide: ", "");
	gonad = getString("Gonad: ", "");
	stage = getString("early or late? ", "");
	current_npixels_pansyp1 = 0;
	current_npixels_syp1phos = 0;
	
//Results Table preparation


//File crawling
for (j = 0; j < sbs_list.length; j++){


open(subsets_directory+sbs_list[j]);
	//variable for main window for Weka segmentation
	main_window = getTitle();
	results_sbs_name = replace(main_window, ".cut - C=2", ".cut");
	previous_npixels_pansyp1 = 0;
	previous_npixels_syp1phos = 0;

	

setResult("sbs", nResults, results_sbs_name);
setResult("stage", nResults-1, stage);
updateResults();

Table.rename( "Results", "FlagResults");



selectWindow(replace(main_window, ".cut - C=2", ".cut - C=0"));
close();
selectWindow(replace(main_window, ".cut - C=2", ".cut - C=1"));
close();
selectWindow(main_window);


//running Weka segmentation with the classifier model
run("Trainable Weka Segmentation");
selectWindow("Trainable Weka Segmentation v3.2.33");
wait(500);
call("trainableSegmentation.Weka_Segmentation.loadClassifier", "/Users/carlos/c016/testing/classifier/"+genotype+"_slide"+slide+"_gonad"+gonad+"_"+stage+"_classifier.model");
wait(500);
call("trainableSegmentation.Weka_Segmentation.getResult");
selectWindow("Classified image");

//splitting model product, adjusting it, saving it and closing weka.
run("RGB Color");
run("Split Channels");
close();
selectWindow("Classified image (red)");
close();
run("Invert", "stack");
run("Divide...", "value=255.000 stack");
selectWindow("Classified image (green)");
black_file = replace(main_window, ".cut - C=2", "_black");
saveAs(".tiff", blacks+genotype+"/slide"+slide+"/gonad"+gonad+"/"+black_file);
selectWindow("Trainable Weka Segmentation v3.2.33");
close();

//opening the file again and closing the other wavelenghts.
	//variable for syp1phos window
	syp1phos_window = replace(main_window, ".cut - C=2", ".cut - C=1");
open(subsets_directory+sbs_list[j]);
selectWindow(main_window);


//Slice crawling to find background corrections
	//Starting variables
	corrected_chromosome_intensity_pansyp1 = 0;
	corrected_chromosome_intensity_syp1phos = 0;
	pansyp1_total_background = 0;
	syp1phos_total_background = 0;
	pansyp1_npixels_total_background = 0;
	syp1phos_npixels_total_background = 0;
	
	
	
	slice_number = nSlices;



for (i=1; i < slice_number; i++) {
slice = i;


//Variables for the final intensity measurement
	previous_npixels_pansyp1 = current_npixels_pansyp1;
	previous_intensity_pansyp1 = corrected_chromosome_intensity_pansyp1;
	corrected_chromosome_intensity_pansyp1 = 0;
	slice_intensity_pansyp1 = 0;
	slice_npixels_pansyp1 = 0;
	slice_chromosome_intensity_pansyp1 = 0;
	slice_chromosome_npixels_pansyp1 = 0;
	current_npixels_pansyp1 = 0;

	
	//syp1phos variables
	previous_intensity_syp1phos = corrected_chromosome_intensity_syp1phos;
	corrected_chromosome_intensity_syp1phos = 0;
	slice_intensity_syp1phos = 0;
	slice_npixels_syp1phos = 0;
	slice_chromosome_intensity_syp1phos = 0;
	slice_chromosome_npixels_syp1phos = 0;
	previous_npixels_syp1phos = current_npixels_syp1phos;
	current_npixels_syp1phos = 0;
	


//open original file and close other wavelengths.
original_pansyp1 = getTitle();
original_dapi = replace(original_pansyp1, "cut - C=2", "cut - C=0");
selectWindow(original_dapi);
close();
original_syp1phos = replace(original_pansyp1, "cut - C=2", "cut - C=1");
selectWindow(original_syp1phos);
run("Duplicate...", "duplicate");
duplicate_syp1phos = replace(original_syp1phos, "cut - C=1", "cut - C=1-1");
selectWindow(original_syp1phos);
close();
open(blacks+genotype+"/slide"+slide+"/gonad"+gonad+"/"+black_file+".tif");
selectWindow(original_pansyp1);
run("Duplicate...", "duplicate");
duplicate_pansyp1 = replace(original_pansyp1, "cut - C=2", "cut - C=2-1");
selectWindow(original_pansyp1);


//Get the pansyp1 chromosomes
imageCalculator("Multiply create stack", duplicate_pansyp1, black_file+".tif");
selectWindow("Result of "+duplicate_pansyp1);
pansyp1_chromosomes = getTitle();
saveAs("tiff", "/Users/carlos/c016/testing/chromosomes/"+replace(duplicate_pansyp1, ".cut - C=2", "_chrom"));
pansyp1_chromosomes = getTitle();

//Get syp1phos chromosomes
imageCalculator("Multiply create stack", duplicate_syp1phos, black_file+".tif");
selectWindow("Result of "+duplicate_syp1phos);
syp1phos_chromosomes = getTitle();
saveAs("tiff", "/Users/carlos/c016/testing/chromosomes/"+replace(duplicate_syp1phos, ".cut - C=1", "_chrom_syp1phos"));
syp1phos_chromosomes = getTitle();


//Threshold to create ROIs pansyp1
selectWindow(pansyp1_chromosomes);
run("Duplicate...", "duplicate");
	//variable for ROI
	threshold_pansyp1_chromosomes = getTitle();
setSlice(slice);
getRawStatistics(nPixels, mean, min, max, std, histogram);
setThreshold(min+1, 65535, "raw");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Light black");
run("Create Selection");
run("Make Inverse");
run("Measure");
	//variable for evaluation
	threshold_chromosome_intensity = getResult("RawIntDen");
selectWindow("Results");
run("Close");


//test to find cropped images
selectWindow(duplicate_pansyp1);
run("Duplicate...", "duplicate");                              
threshold_window = replace(original_pansyp1, "cut - C=2", "cut - C=2-2");
selectWindow(threshold_window);
saveAs("tiff", "/Users/carlos/c016/testing/threshold/"+replace(threshold_window, ".cut - C=2-2", "_threshold"));
threshold_window = getTitle();
getRawStatistics(nPixels, mean, min, max, std, histogram);
	//variable for cropped test
	crop_test_total_npixels = nPixels;
setThreshold(min+1, 65535, "raw");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Light black");
run("Create Selection");
getRawStatistics(nPixels, mean, min, max, std, histogram);
	//variable for cropeed test
	crop_test_min_pixels = nPixels;

//actual test
if(crop_test_min_pixels/crop_test_total_npixels < 0.1){

	Table.rename("FlagResults", "Results");
	updateResults();
	setResult("crop", nResults-1, "no");
	Table.rename("Results", "FlagResults");

if (threshold_chromosome_intensity >= 1) {

//pansyp1 slice intensity if not cropped
selectWindow(duplicate_pansyp1);
setSlice(slice);
getRawStatistics(nPixels, mean, min, max, std, histogram);
	//variable number of pixels pansyp1
	slice_npixels_pansyp1 = nPixels;
run("Measure");
selectWindow("Results");
	//variable slice intensity pansyp1
	slice_intensity_pansyp1 = getResult("RawIntDen");
IJ.renameResults("temporal_intensity");
selectWindow("temporal_intensity");
run("Close");

//syp1phos slice intensity if not cropped
selectWindow(duplicate_syp1phos);
setSlice(slice);
getRawStatistics(nPixels, mean, min, max, std, histogram);
	//variable number of pixels pansyp1
	slice_npixels_syp1phos = nPixels;
run("Measure");
selectWindow("Results");
	//variable slice intensity pansyp1
	slice_intensity_syp1phos = getResult("RawIntDen");
IJ.renameResults("temporal_intensity");
selectWindow("temporal_intensity");
run("Close");


//pansyp1_chromosomes calculations
	selectWindow(threshold_pansyp1_chromosomes);
	roiManager("Add");
	selectWindow(pansyp1_chromosomes);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
		//variable number of pixels pansyp1 chromosomes
		slice_chromosome_npixels_pansyp1 = nPixels;
		run("Measure");
		//variable chromosome intensity syp1phos
		slice_chromosome_intensity_pansyp1 = getResult("RawIntDen");
	roiManager("Deselect");
	selectWindow("Results");
	run("Close");

//syp1phos_chromosomes calculations
	selectWindow(syp1phos_chromosomes);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	slice_chromosome_npixels_syp1phos = nPixels;
	run("Measure");
	slice_chromosome_intensity_syp1phos = getResult("RawIntDen");
	roiManager("Deselect");
	selectWindow("Results");
	run("Close");
	roiManager("Delete");

	//Calculate slice background pansyp1
	slice_total_npixels_pansyp1 = slice_npixels_pansyp1-slice_chromosome_npixels_pansyp1;
	slice_total_intensity_pansyp1 = slice_intensity_pansyp1-slice_chromosome_intensity_pansyp1;
	average_slice_background_pansyp1 = slice_total_intensity_pansyp1 / slice_total_npixels_pansyp1;
	
	//Calculate slice background pansyp1
	slice_total_npixels_syp1phos = slice_npixels_syp1phos-slice_chromosome_npixels_syp1phos;
	slice_total_intensity_syp1phos = slice_intensity_syp1phos-slice_chromosome_intensity_syp1phos;
	average_slice_background_syp1phos = slice_total_intensity_syp1phos / slice_total_npixels_syp1phos;

				
	//Calculate chromosome corrected values pansyp1
	chromosomes_background_pansyp1 = slice_chromosome_npixels_pansyp1*average_slice_background_pansyp1;
	chromosomes_slice_corrected_intensity_pansyp1 = slice_chromosome_intensity_pansyp1 - chromosomes_background_pansyp1;
	corrected_chromosome_intensity_pansyp1 = previous_intensity_pansyp1+chromosomes_slice_corrected_intensity_pansyp1;	
	current_npixels_pansyp1 = slice_chromosome_npixels_pansyp1+previous_npixels_pansyp1;

	//Calculate Total Background values
	pansyp1_total_background = pansyp1_total_background+slice_total_intensity_pansyp1;
	syp1phos_total_background = syp1phos_total_background+slice_total_intensity_syp1phos;
	pansyp1_npixels_total_background = pansyp1_npixels_total_background+slice_total_npixels_pansyp1;
	syp1phos_npixels_total_background = syp1phos_npixels_total_background+slice_total_npixels_syp1phos;



	//Calculate chromosome corrected values syp1phos
	chromosomes_background_syp1phos = slice_chromosome_npixels_syp1phos*average_slice_background_syp1phos;
	chromosomes_slice_corrected_intensity_syp1phos = slice_chromosome_intensity_syp1phos - chromosomes_background_syp1phos;
	corrected_chromosome_intensity_syp1phos = previous_intensity_syp1phos+chromosomes_slice_corrected_intensity_syp1phos;	
	current_npixels_syp1phos = slice_chromosome_npixels_syp1phos+previous_npixels_syp1phos;


	print("pansyp1");
	print(chromosomes_slice_corrected_intensity_pansyp1);
	print(corrected_chromosome_intensity_pansyp1);
	print("");
	print("syp1phos");
	print(chromosomes_slice_corrected_intensity_syp1phos);
	print(corrected_chromosome_intensity_syp1phos);
	print("");
	print("");
			
	//Close all other windows
		while (nImages>0) { 
    	selectImage(nImages); 
    	close(); 
    	} 

	
	
	open(subsets_directory+sbs_list[j]);
	
	//end of last IF	

}

else{
	print(i);
	
	corrected_chromosome_intensity_pansyp1 = previous_intensity_pansyp1+0;
	corrected_chromosome_intensity_syp1phos = previous_intensity_syp1phos+0;
	current_npixels_pansyp1 = slice_chromosome_npixels_pansyp1+previous_npixels_pansyp1;
	current_npixels_syp1phos = slice_chromosome_npixels_syp1phos+previous_npixels_syp1phos;
	pansyp1_total_background = pansyp1_total_background+0;
	syp1phos_total_background = syp1phos_total_background+0;
	pansyp1_npixels_total_background = pansyp1_npixels_total_background+0;
	syp1phos_npixels_total_background = syp1phos_npixels_total_background+0;


	
	while (nImages>0) { 
    selectImage(nImages); 
    close(); 
    } 
	open(subsets_directory+sbs_list[j]);
		
	//end of ELSE
}

	
}

else{

Table.rename("FlagResults", "Results");
	updateResults();
	setResult("crop", nResults-1, "yes");
	Table.rename("Results", "FlagResults");

//Find out if there's a chromosome in the slide
if (threshold_chromosome_intensity >= 1) {
	//Threshold to create ROIs background
	setSlice(slice);
	run("Create Selection");
	run("Make Inverse");
	roiManager("Add");
	roiManager("Deselect");
	

	//Get the pansyp1 slice RawIntDen and Statistics 
	selectWindow(duplicate_pansyp1);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
		//variable number of pixels pansyp1
		slice_npixels_pansyp1 = nPixels;
	run("Measure");
	selectWindow(duplicate_pansyp1);
	roiManager("Deselect");
	roiManager("Show All with labels");
	selectWindow("Results");
		//variable slice intensity pansyp1
		slice_intensity_pansyp1 = getResult("RawIntDen");
	IJ.renameResults("temporal_intensity");
	selectWindow("temporal_intensity");
	run("Close");

	//Get the syp1phos slice RawIntDen and Statistics 
	selectWindow(duplicate_syp1phos);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
		//variable number of pixels syp1phos
		slice_npixels_syp1phos = nPixels;
	run("Measure");
	selectWindow(duplicate_syp1phos);
	roiManager("Deselect");
	roiManager("Delete");
	roiManager("Show All with labels");
	selectWindow("Results");
		//variable slice intensity syp1phos
		slice_intensity_syp1phos = getResult("RawIntDen");
	IJ.renameResults("temporal_intensity_syp1phos");
	selectWindow("temporal_intensity_syp1phos");
	run("Close");
	
	//pansyp1_chromosomes calculations
	selectWindow(threshold_pansyp1_chromosomes);
	roiManager("Add");
	selectWindow(pansyp1_chromosomes);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
		//variable number of pixels pansyp1 chromosomes
		slice_chromosome_npixels_pansyp1 = nPixels;
		run("Measure");
		//variable chromosome intensity syp1phos
		slice_chromosome_intensity_pansyp1 = getResult("RawIntDen");
	roiManager("Deselect");
	selectWindow("Results");
	run("Close");
	
	//syp1phos_chromosomes calculations
	selectWindow(syp1phos_chromosomes);
	setSlice(slice);
	roiManager("Select", 0);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	slice_chromosome_npixels_syp1phos = nPixels;
	run("Measure");
	slice_chromosome_intensity_syp1phos = getResult("RawIntDen");
	roiManager("Deselect");
	selectWindow("Results");
	run("Close");
	roiManager("Delete");

		
	//Calculate slice background pansyp1
	slice_total_npixels_pansyp1 = slice_npixels_pansyp1-slice_chromosome_npixels_pansyp1;
	slice_total_intensity_pansyp1 = slice_intensity_pansyp1-slice_chromosome_intensity_pansyp1;
	average_slice_background_pansyp1 = slice_total_intensity_pansyp1 / slice_total_npixels_pansyp1;

	//Calculate slice background syp1phos
	slice_total_npixels_syp1phos = slice_npixels_syp1phos-slice_chromosome_npixels_syp1phos;
	slice_total_intensity_syp1phos = slice_intensity_syp1phos-slice_chromosome_intensity_syp1phos;
	average_slice_background_syp1phos = slice_total_intensity_syp1phos / slice_total_npixels_syp1phos;

	//Calculate Total Background values
	pansyp1_total_background = pansyp1_total_background+slice_total_intensity_pansyp1;
	syp1phos_total_background = syp1phos_total_background+slice_total_intensity_syp1phos;
	pansyp1_npixels_total_background = pansyp1_npixels_total_background+slice_total_npixels_pansyp1;
	syp1phos_npixels_total_background = syp1phos_npixels_total_background+slice_total_npixels_syp1phos;

				
	//Calculate chromosome corrected values pansyp1
	chromosomes_background_pansyp1 = slice_chromosome_npixels_pansyp1*average_slice_background_pansyp1;
	chromosomes_slice_corrected_intensity_pansyp1 = slice_chromosome_intensity_pansyp1 - chromosomes_background_pansyp1;
	current_npixels_pansyp1 = slice_chromosome_npixels_pansyp1+previous_npixels_pansyp1;
	corrected_chromosome_intensity_pansyp1 = previous_intensity_pansyp1+chromosomes_slice_corrected_intensity_pansyp1;	


	//Calculate chromosome corrected values syp1phos
	chromosomes_background_syp1phos = slice_chromosome_npixels_syp1phos*average_slice_background_syp1phos;
	chromosomes_slice_corrected_intensity_syp1phos = slice_chromosome_intensity_syp1phos - chromosomes_background_syp1phos;
	current_npixels_syp1phos = slice_chromosome_npixels_syp1phos+previous_npixels_syp1phos;
	corrected_chromosome_intensity_syp1phos = previous_intensity_syp1phos+chromosomes_slice_corrected_intensity_syp1phos;	


	print("pansyp1");
	print(chromosomes_slice_corrected_intensity_pansyp1);
	print(corrected_chromosome_intensity_pansyp1);
	print("");
	print("syp1phos");
	print(chromosomes_slice_corrected_intensity_syp1phos);
	print(corrected_chromosome_intensity_syp1phos);
	print("");
	print("");
			
	//Close all other windows
		while (nImages>0) { 
    	selectImage(nImages); 
    	close(); 
    	} 

	
	
	open(subsets_directory+sbs_list[j]);
	
	//end of last IF	
	}

	
	else {

	print(i);
	
	corrected_chromosome_intensity_pansyp1 = previous_intensity_pansyp1+0;
	corrected_chromosome_intensity_syp1phos = previous_intensity_syp1phos+0;
	current_npixels_pansyp1 = slice_chromosome_npixels_pansyp1+previous_npixels_pansyp1;
	current_npixels_syp1phos = slice_chromosome_npixels_syp1phos+previous_npixels_syp1phos;
	pansyp1_total_background = pansyp1_total_background+0;
	syp1phos_total_background = syp1phos_total_background+0;
	pansyp1_npixels_total_background = pansyp1_npixels_total_background+0;
	syp1phos_npixels_total_background = syp1phos_npixels_total_background+0;


	while (nImages>0) { 
    selectImage(nImages); 
    close(); 
    } 
	open(subsets_directory+sbs_list[j]);
		
	//end of ELSE
	}

}

//setResult("Background", nResults-1, corrected_chromosome_intensity);
//updateResults();



//End of FOR loop
}

	Table.rename("FlagResults", "Results");
	updateResults();
	setResult("panSYP-1 Corrected", nResults-1, corrected_chromosome_intensity_pansyp1);
	setResult("SYP-1Phos Corrected", nResults-1, corrected_chromosome_intensity_syp1phos);
	setResult("nPixels phos", nResults-1, current_npixels_syp1phos);
	setResult("nPixels pan", nResults-1, current_npixels_pansyp1);
	setResult("pansyp1_background", nResults-1, pansyp1_total_background);
	setResult("pansyp1_background_pixels", nResults-1, pansyp1_npixels_total_background);
	setResult("syp1phos_background", nResults-1, syp1phos_total_background);
	setResult("syp1phos_background_pixels", nResults-1, syp1phos_npixels_total_background);
	updateResults();
	current_npixels_pansyp1 = 0;
	current_npixels_syp1phos = 0;

	while (nImages>0) { 
    selectImage(nImages); 
    close(); 
    } 

	


}

selectWindow("Results");
saveAs("Results", ints+genotype+"/slide"+slide+"/gonad"+gonad+"/"+genotype+"_slide"+slide+"_gonad"+gonad+"_"+stage+"_intensities.csv");