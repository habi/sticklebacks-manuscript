---
title: "Revisions for *High-Throughput Micro-CT and Automated Segmentation for Eco-Evolutionary Studies: A Case Study from Threespine Stickleback*"
subtitle: "In the course of implementing the revisions we changed the title of the manuscript to *From multi-specimen scans to individual bones: automated extraction and efficient, label-guided segmentation of stickleback micro-CT data*"
author: David Haberthür
date: 
---

<!--
Text is copy-pasted from the email we got, block-quoted *in toto*, answered inbetween.
Use
```bash
pandoc answer.md \
  --output=answer.pdf \
  --to=typst-citations \
  --from=markdown \
  --lua-filter=quote-style.lua \
  --citeproc \
  --bibliography="$HOME/Documents/library.bib" \
  --csl="../../build/assets/style.csl" \
  --pdf-engine=typst
```
to make a PDF with nicely styled quotes and link underlines (hat tip to ChatGPT for whipping up the lua styling filter (I only changed the color to UniBe red)) and references (using the manubot CSL in this repo)
-->

## Summary of major changes

We thank the editor and both anonymous reviewers for their careful assessment of our manuscript and the constructive comments.
Below, we are quoting and numbering all comments verbatim, the given line numbers refer to the revised manuscript.

To state the contributions more precisely (AE.2, AE.4), we changed the title of the manuscript to "From multi-specimen scans to individual bones: automated extraction and efficient, label-guided segmentation of stickleback micro-CT data".

Both reviewers stated that the manual reordering of the detected labels is at least inelegant (R2.14, R2.15).
We improved our separation script and replaced the manual reordering of detected regions by an assignment based on each region's angle around the rotation axis. Re-running the pipeline on all 38 scans reproduces the previous output bit-for-bit; the only manual input left (compartment number to fish ID) is now stated explicitly.

Following comments on the structuring of the discussion (AE.3, R1.1, R2.2) we split the discussion into sections on data acquisition, the pipeline and its efficiency (including comparison with other multi-specimen workflows and alternative segmentation tools), and limitations.

Based on comments on the sample mounting (R2.8) and holder material (R2.11), and the question why we scanned a larger region than analyzed, we expanded the methods section and added an explanation on the newly implemented angle-based assignment (R2.14).

The results section was corrected and clarified.
We now report correct total dataset size (385 GB, previously misreported as 64 GB) and mention the dimensions of the cropped datasets (R1.15, R2.27).
Memory requirements and the feasibility of an ImageJ-based approach (R1.17, R2.21, R2.22), and the role of the multi-level thresholding (R2.28) was added.

We completely overhauled Figure 1 and expanded its caption (R1.2, R2.6).
Captions of Figures 2, 4 and 6 were clarified (R1.6, R1.8, R1.13) and included the forgotten supplementary material (R1.22).
We also more prominently linked to the exported datasets of all cropped regions available on MorphoSource.

## Associate Editor Comments to Author

### AE.1

> I would like to thank the authors for their contribution, this is an interesting study detailing a pipeline that would be of interest and use for many researchers.
> However, the manuscript does not provide sufficient evidence for the claim that this pipeline is replicable and clade-agnostic, which would require testing on different specimens, across different taxonomic groups.

Thanks for this supportive comment, appreciated.
### AE.2

> The pipeline itself should be better defined.
> The abstract states "The pipeline includes separation of multi-species scans into individual regions of interest, reconstruction of targeted anatomical structures, and morphometric analyses.", but the landmarking and geometric morphometric analyses detailed are conducted using established software and methods (manual landmarking in Checkpoint, analysis in R), that are not a novel or unique part of the pipeline developed for this paper.
> The current text obscures the actual contribution of the work.

The separation pipeline itself is *defined* in the presented code.
The extraction of the anatomical structures, landmarking and geometric morphometric analysis *are* conducted using established software, but are essential parts of the presented pipeline, albeit neither novel nor unique as you correctly state.
### AE.3

> As discussed by Reviewer 2, the pipeline is underexplained and, as mentioned by Reviewer 1 the discussion is brief and does not sufficiently discuss the pipeline, its advantages or disadvantages.

### AE.4

> There is general lack of detail throughout the text: the introduction does not mention alternative methods or sufficiently explain why this pipeline was developed.
> It is true that time and resources are required to segment scans, and these factors compound as the number of specimens increases, but what does this pipeline solve uniquely or better than existing methods.

One of the main benefits we see in our separation pipeline is the end-to-end reproducibility, i.e. if it's run again on the acquired data we get exactly the same output (separated specimen regions).
In the course of implementing the revisions for this manuscript we changed the resorting/labeling logic of the extracted regions to make that part of the pipeline *fully* automatic, and ran the splitting/cropping notebook again on the full input data on our local machine.
The results were bit-for-bit the same as what was present on the network folder shared by all co-authors.
This strengthens our argument on the automated separation of the individual fish from the multi-specimen scans.
As it is now, the separation part of the pipeline is applicable to any multi-object scan where the objects can be separated in the top-down axial view of the original to split these objects into individual datasets.
We concede that the further steps in our pipeline are generally agnostic to the software used, but the chosen combination of SlicerMorph and Biomedisa offers great scalability and keeps all parts of the workflow in Free and open-source software.

### AE.5

> There are many pieces of software used for processing scans, separating out specimens and segmentation, which could warrant discussion, including:
>
> - Segment Anything Model (SAM) and SAM2
> - Computer Vision and Deep Learning pipelines in AVIZO, Dragonfly and Slicer
> - nnInteractive
> - BounTI
> - SPROUT
> - Existing protocols in ImageJ/Fiji

Thank you for the suggestions!
The editor is absolutely correct that there are many pieces of software that can be used for processing scans, separating out specimens and segmentation.
The processing and separating part is done fully automated in our pipeline, which we see as a great help to facilitate high-throughput studies in a reproducible fashion.

Some details on the mentioned software:

- All the mentioned items are somehow connected, and could act interchangeably in our model.
- SPROUT, BounTI and nnInteractive are especially interesting, as SPROUT was inspired by BounTI, and SPROUT can use nnInteractive as its prediction backend.
- SAM/SAM2/SAM 3D, while excellent for 2D images, fall rather short in non-medical datasets (as demonstrated quite nicely in Isensee et al's preprint on nnInteractive, [@Isensee2025, Figure 7]).
- While we use Slicer and associated tools in this manuscript, the creation of labels for the training step can be done with any program that can create segementation labels (including but not limited to Slicer, NNInteractive, Avizo and Dragonfly tools, BounTI, and SPROUT).
  We see this growing field as complementary to our work, as it decreases the time required to build quality segmentations necessary for Biomedisa training (indeed, the preprint for SPROUT [@He2025] does this directly).

So, Biomedisas deep learning mode can in principle be combined with any of the above as a pre- or post-processing step, and works particularly well as an online platform with no local install or on the cluster infrastructure of the University of Bern, so the choice of it was driven by reaching a local optimum in our workflow.

We explain the reproducibility and automation of the presented notebooks in more detail and expanded the discussion on alternatives and additional tools.

## Reviewer(s)' Comments to Author

### Reviewer: 1

> Overall, this is a well-written study that will assist others in conducting similar research.
> There are just a few points I found difficult to follow, and clarifying them would be beneficial for future readers.
> A somewhat more significant criticism concerns the discussion: it is very brief and focuses primarily on the biological results, while neglecting the method or pipeline described.
> A more detailed discussion of the advantages and disadvantages, as well as the potential applications and limitations of the method (when it works, when it does not, and why), would be helpful for the readership.

We thank the reviewer for the general, positive assessment and the very constructive criticism.
We agree that the discussion focused on the biological results too heavily.
It now contains dedicated sections describing data acquisition, the pipeline itself and its efficiency, and discusses limitations of our approach.

#### R1.2

> Perhaps some of the following questions could be addressed in this context:
>
> Figure 1 is impossible to read.
> Please enlarge the text and maybe add some description in the caption.

We updated the figure showing the workflow in a so-called swimlane layout, giving it more breathing room and improved the caption.

#### R1.3

> Line 98ff: “DNA was extracted […], and subsequent PCR genotyping […] was performed […]”.
> Why is this relevant to this study?

Sexual dimorphism is a potential explanatory factor for ceratobranchial shape, and sex assignments from preserved specimens can be difficult; genotyping gives a less ambiguous designation.
We rewrote this line to explain this ([L##]).

#### R1.4

> Line 119: You mention that different voltage and current were used for one scan, due to operator error.
> How did that affect the scan quality and subsequent segmentation?

#### R1.5

> Line 123: You scanned 3 fields of view.
> How were they merged/stacked?

Merging of the substacks is performed automatically in the reconstruction software NRecon provided by Bruker.
The merging does correct for minute differences in rotation and usually works absolutely flawlessly by blending the overlapping regions in the reconstructed stack, so there are also no cone-beam reconstruction artifacts discernible.
#### R1.6

> Line 129: I don’t understand what you mean by “shown extracted”.

As a non-native English writer (one of the first authors), we chose the wrong word here.
#### R1.7

> Line 130: I assume it should be “Figure 4” not just “4”.

#### R1.8

> Line 132: Which tool/software was used to render Figure 2?

#### R1.9

> Line 155: First, “Simple” is very subjective.
> I would remove it.

#### R1.10

> Line 155: Second, I understand you binarized the data using Otsu thresholding and then used skimage.measure.label to label connected components (each fish) with an individual label value.
> Thinking in 3D, I agree that the fish should not overlap, because each one is located in a dedicated container.
> In Lines 254-255 you also write that the regions don’t overlap.
> But looking at your Figure 4, it seems that fish 2 and 3 are touching.
> So how is this separation process still possible?

The reviewer is correct that the fish do not overlap in 3D.
Because the 3D-printed holder is slightly warped, it is tilted by about 3.25° in the scanner (see the stitched preview image below), so the tail of fish 2 overlaps the head of fish 3 in the axial MIP only.
Since each region is cropped with a 50-pixel buffer, neighbouring cropped regions can overlap and may contain a small part of the adjacent fish; this did not affect any further analysis.

![Preview image of Sticklebucket_H (the scan shown in Figures 2--6), showing the tilt of the sample holder. Shown for illustration only, as it does not add information relevant to the manuscript.](Sticklebucket_H_rec_spr.png)

#### R1.11

> Figure 4: I assume the numbers in the right image are the label values automatically assigned by skimage.
> Is that correct.
> Were they assigned manually to the correct fish ID (which I assume are the yellow numbers)?

Your assumption is correct, the labels in the black circles are the ones assigned by `skimage.label` in raster order from top left to bottom right.
The yellow numbers in the left panel of the Fig. 4--6 (and the ones that were red in Fig. 2 (now yellow, too)) are the ones "imprinted" on the sample holder by the 3D printer, simply highlighted on this image by a step in our script (not described in detail in the manuscript).
Assignment/Matching of compartment number to detected label to fish ID was performed manually on the first half of the scans and performed in the script for the second half of the scans.
The matching for the second half of the scans was performed by writing a small text file matching compartment number to fish ID, where the script then read this file.
#### R1.12

> Line 169: I don’t think skimage.measure.regionprops is “labeling” the data.
> It only provides properties of the regions labeled by skimage.measure.label.

#### R1.13

> Figure 6: I understand that this is a verification step to ensure the cropping worked correctly.
> But I don’t understand what was done.
> To me, both rows show the exact same extracted region from the MIP images.
> What could potentially have gone wrong, and what would the images look like?

As specified in the figure caption both rows *must* show the same image (except the yellow highlight).
The top row is cropped from the MIP of the multi-specimen scan, the bottom is the MIP calculated from each cropped dataset.
We've expanded the caption accordingly.

#### R1.14

> Figure 8: Were all the different structures used for model training or only CB1 and CB2.
> And were CB1 and CB2 labeled differently or with the same label value.
> Figure 8 suggests they have the same value.

All structures were used for model training, with all ceratobranchials (including CB1 and CB2 having the same value) yet still distinguishable in the scan output.
#### R1.15

> Line 212: Could you provide the range of image dimensions of the cropped images.
> From the supplementary data, I gathered that x and y dimensions are approximately 500 voxels, but what about the z dimension?
> Were the regions manually or automatically cropped to the head, or was only the field of view containing the head processed?
> If the entire fish was processed there might be substantial resizing artifacts, because the default behavior of Biomedisa is to resample the input data to 256x256x256 voxels before processing.

The exported datasets range from 486 × 722 × 1743 voxels (x, y, z) to 1322 × 862 × 5398 voxels, with a median of about 4250 × 650 × 650 voxels (anteroposterior length × x × y), stored as uncompressed 8-bit volumes.

The smallest sized crop is from a scan that didn't turn out good (see [this README file of one of these scans](https://anonymous.4open.science/r/sticklebacks-01A4/logfiles/Sticklebucket_14/README.md)), but was nonetheless a scan where we used the scanned head-region of the fish for extracting the rakers.
The same folder does contain datasets spanning the whole fish, so the *median* size of the cropped regions is a better estimate of the sizes.

While compiling these numbers, we noticed that the total size was misreported: it is 385 GB, not 64 GB.
Both values are corrected in the Results ([L##]).

The reviewer is correct.
We used Biomedisa with its default settings, so all datasets were resampled to 256 × 256 × 256 voxels for training and prediction, and the predicted labels were scaled back to the original resolution.
The landmarks describe the overall shape of CB1 and CB2 (end points and curves along the bones), all specimens were processed identically, and remaining errors (adjacent bones merged in the prediction) were corrected manually.
We therefore do not expect the resampling to affect the comparisons between lakes and ecotypes.
We now state the resampling in the Methods and mention fine structures, such as gill rakers, as a limitation in the Discussion ([L##]).
#### R1.16

> How were the training labels created.
> Manually?

#### R1.17

> Line 262: “7 GB on disk and reported as 35.4 GB”.
> This suggests that the data is compressed.
> Maybe mention the compression method and could you also provide the data type (e.g., 16-bit unsigned integer)?

The reconstructions are stored as losslessly compressed 8-bit PNG files; the cropped `nrrd` datasets are uncompressed 8-bit volumes.
Fiji reports the size of the decompressed stack in memory (for the example now used in the text: 3064 × 3064 pixels × 4891 slices × 1 byte = 42.8 GB, versus 8.5 GB on disk).
This memory is only needed when loading the full stack, not for a virtual stack; we clarified this in the Results ([L##]).

#### R1.18

> Table 1: Maybe call it “Our Pipeline Time”.

#### R1.19

> In all of your test statistics, the symbol identifying the test statistic is missing.

#### R1.20

> Line 323: “The The benthic”.
> Redundant “The”

#### R1.21

> Line 341: species/species.
> Redundant “species”

#### R1.22

> Line 350: There are no supplementary figures.

### Reviewer 2

#### R2.1

> This paper presents a pipeline that make it possible to analyse a large corpus (215 specimens) of fishes with geometric morphometrics on internal structures only accessible with micro-CT.
> The time constraints that led to develop the pipeline are well explained.
> Most of the pipeline runs with Jupyter notebooks and open libraries or softwares, which is appreciated when a project involves different collaborators in an OpenScience approach.

#### R2.1

> The paper lacks a few references to protocols aiming at optimizing the workflow of CTscanning multiple specimens, focusing on either mounting specimens together or automatizating the post-processing the data, or both.
> Discussion would benefit from comparisons with those protocols (fishes in the #ScanAllFish project, other high-throughput micro-CT scanning for 3D morphometrics studies).

We thank the reviewer for this suggestion.
We improved the discussion by comparing our approach in the context of other high-throughput micro-CT protocols, be it for workflows scanning many small shells or the fish-scanning effort of Adam P. Summers lab.
Since the work presented in this manuscript is only *one* of the many projects going in our lab, streamlining (and automation) of the separation process mattered even more.
#### R2.3

> The pipeline could be further optimized, some steps are redundant or not justified enough.
> The code relies too much on hard-written adjustments or manual corrections, especially in the separation notebook.

Thanks to your detailed input on the (manual) resorting of the labels we improved the separation pipeline.
The radial resorting of the detected labels is as robust as possible and now makes the separation step fully automated (except noting which fish is in which petal of the multi-specimen holder).
We honestly thank the reviewer to bring this point forward and were able to greatly improve the quality and robustness of the separation pipeline, without altering the output of the pipeline.
This ultimately led us to change the title of the manuscript, laying focus on the automated separation of specimen and efficient segmentation.

> As such, the pipeline is sometimes confusing.
> I suggest some revisions to clarify the authors' approach and make the pipeline more robust.
> The claim that the pipeline is replicable and clade-agnostic should be adapted to the amount of revisions that can be done to reach this objective.

#### R2.5

> Line 71-72: « Furthermore, accessing these structures requires destruction of the mandibular and cranial anatomy, preventing subsequent analyses of these features” refers to the destructive dissection of the structures of interest and does not fit in this paragraph where the authors describe the non-destructive benefits of micro-CT.

#### R2.6

> Figure 1: The font is too small, please consider editing a more readable figure.
> The sample positioning in the holder is a required step in the workflow that should be visible between sample collection and microCT imaging.

#### R2.7

> Line 83: the title seems incomplete

#### R2.8

> Sample positioning
> Extra information is needed regarding the specimens.
> The authors describe individual bags with a formalin solution and later show pictures of tubes holding a fish and some liquid.
> How where the fishes placed into the sample holder to ensure that they won’t create a movement artefact and/or dry as the scans duration is 10h?
> There is a mention of foam in the notebook, can the authors elaborate ?

#### R2.9

> The sample positioning and reporting in the lab book is a time-consuming task that should be taken into account in the time estimates in Table 1.

Putting the fish into the sample holder, reporting in the lab book and sample positioning really didn't take longer than 30 minutes for each scan, making it a negligible contribution to the scanning time.
Since this step is required for every micro-CT scan, manual or automated, we did not add it to Table 1.

#### R2.10

> There is focus in this study on the feeding structures and the branchial anatomy but it is not explained why the authors chose to scan the whole fishes with all the consequences in terms of scanning time and post-processing heavy datasets.
> From Figure 3., we can see that almost half the dataset is outside these regions of interest, so probably two fields of view instead of three along the rotation axis would have been enough.
> This needs to be addressed and justified.

The datasets will also be used in follow-up studies of other anatomical regions, which required us to scan the total anteroposterior length of each fish.
In addition, the 3D-printed compartment labels have to be within the field of view (visible as the upside-down "1" in Figure 7) to link each cropped dataset to the labeled tube, lab book notes and photos.
We added this justification to the Methods ([L##]).

#### R2.11

> I could not acess the OpenScad files due to the anonymization process of the paper.
> A picture of the sample holder containing the fishes would be appreciated.
> The printing material can be documented as it needs to be radio-transparent enough.
> What are the benefits of the petal design when the central zone needs to be later removed in the separation process ?

#### R2.12

> Line 126: Can the authors elaborate on why they chose not to apply any beam hardening correction .
> How did the beam hardening was checked not to have an impact on the segmentation of small bony structures close to denser structures like otoliths or remaining dense particles ?

We performed pilot scans for this study and did *not* observe classic cupping beam hardening artifacts, as specified for example in [@Orhan2020, section 4.2.1.1].
Faint streaking artifacts close to the teeth and otoliths are visible in the reconstructions, but only discernible by eye if the contrast/brightness of the reconstructions is increased.
But we also did *not* fully study the influence of no or very moderate beam hardening correction through the full pipeline and kindly refrain from doing so.
The influence of the beam hardening correction as explained below on the segmentation and cleaning of the elements of the branchial apparatus using a combination of thresholding and "Split Islands" as specified in the manuscript are in our opinion *completely* negligible.

Nonetheless, now that you highlighted this potential issue we looked at it in a bit more detail.
We thus reconstructed the head-region of one multi-specimen scan (`BucketOfFish_H`) with beam hardening correction varying from 0% to 100% in 10% steps (NRecon only allows for setting the correction between 0% and 100%, no further parameters can be tuned).
Using a custom made notebook (`BeamHardening.ipynb` in the (anonymized) repository), we extracted both the histograms of the regions (2001 x 3064 x 3064 px) and plotted the gray value mean across the horizontal wall of the holder in one of the reconstructions.

The gray value histograms of the regions reconstructed with different beam hardening corrections *do* show differences, but the discernible differences are present in the gray value ranges around 20 (for the plastic in the holder mostly) and around 170 (the bone region).
The differences in the bone region are only very minute and really only visible/discernible in the plot due to the logarithmic scale, as seen below.
Keep in mind that 5 x 10^4 voxels that show the difference are *very* few compared to the 1.8 x 10^10 voxels of these whole datasets.

![Gray value histograms of datasets reconstructed with different beam hardening correction value](Sticklebucket_H.Combined.Histograms.Beamhardening.png)

Plotting the gray value profile mean across the horizontal plastic wall of the multi-specimen holder with increased contrast shows that this gray value varies from 18--23, and---if looking really hard---a very slight cupping might be visible in the completely uniform material at *no* beam hardening correction.
The coefficient of variation of the gray value mean through the wall is at its lowest when the beam hardening correction is performed at 20% and increases greatly when the correction is increased to 100%, showing pronounced over-correction.
Additionally, since the beam hardening correction in NRecon corrects for a radial gray value cupping effect, the influence of the correction on the specimens aligned radially in the multi-specimen holder at nearly identical radii is even more negligible.
In all honesty, we believe that *no* beam hardening correction was necessary for the reconstruction of these datasets.

#### R2.13

> Preview notebook
> A general remark on the preview notebook is that it is not clear what scanning issues are detected then that could not have been seen while reconstructing the data in Nrecon.
> Could the authors elaborate on why the CT operator was not in charge of this check, while the specimens are still in the lab .
> It sounds counter-productive to re-open everything later and maybe having to come back to CTscan again what went wrong.
> The following steps (XY-alignment, ring removal, beam hardening, defect pixel masking, checking for overexposure) should be mandatory in a robust reconstruction protocol, before exporting the slices from Nrecon.
> MIP images could be easily generated with CTan or ImageJ using virtual stack, on the reconstruction computer for a quality assessment before storing the datasets and sending them to the collaborators.

The fish were scanned in two batches over around seven months in total (BucketOfFish_A–U from 2023-11-10--2024-03-27 (about 4.5 months) and Sticklebucket_01–17 from 2025-04-08--2025-06-18 (about 2.5 months)).
This was done in between *many* other projects on the same scanner.
The reconstruction software NRecon from Bruker keeps the last used set of reconstruction parameters when a new scan is loaded, if the operator forgets to set a parameter correctly (or left it at a *wildly* different (good) value for other projects), a consistency check per project is a good step *after* reconstruction.
Our notebook performs this check globally for the project instead of highlighting *scanning* issues of a single scan, which are corrected as soon as detected (and was corrected, too for some scans, something we don't mention in the manuscript.).
The fish were only returned to the Institute of Ecology and Evolution (actually ony about 300m apart) after this quality control was done, so a rescan was possible at any time.

#### R2.14

> Separation notebook
> A major issue in the separation workflow is that the region detection numbers the fishes from left to right starting at the top-left of the image while the sample holder numbers the fishes from 1 to 6 counter-clockwise.
> This results in a wrong allocation as visible on Figure 4. and a need to reorder the list for each bucket, as visible in Figure 5.
> The calculated labels do not fit the sample holder labels in every 38 scans, and the labelling is different w.r.t the sizes of the fishes within their petal.
> When reviewing the notebook code, it appears that each list has been manually edited in the reorder_list function.

#### R2.15

> The statement that the extraction process is fully automatic and reproductible does not hold.
> The authors should comment on that error and how to correct the labels efficiently.
> In my opinion, the way it is handled now makes the pipeline flawed.
> As a manual reordering of the labels is needed anyway, the authors should acknowledge it and come up with a cleaner way to let the operator assign the labels within the notebook.

#### R2.16

> In order to validate the separation method, creating a MIP of the cropped version and comparing with the full scan MIP seems enough.
> It is confusing to me why the authors go through a multilevel threshold that shows an interactive rendering within the notebook.
> The fishs are not cropped in the anterior-posterior direction and even if they were, a frontal MIP would provide enough information to check if the crop went well.
> This multilevel threshold does not seem to be later used in the segmentation process (note: it could have been loaded into 3Dslicer as a seg.nrrd file to speed up the thresholding step).
> The workflow could be simplified with discarding the interactive rendering and the need to keep a .zarr version of the cropped files.
> Dealing with storage limitations, it is quite inefficient to keep three versions of the same dataset, only the .nrrd is needed from here to the end of the pipeline and can be handled with skimage.

We agree that the axial MIP is sufficient to validate the separation, and that the multi-level thresholding and the interactive rendering are not needed for the results of this manuscript (the rendering produced Figure 7).
We keep the thresholding in the notebook because the binarized datasets are used in follow-up studies; the Results now state this explicitly (see R2.28).

The `zarr` files served as intermediate storage, as they are *extremely* well suited to store n-dimensional arrays on disk and support chunking, compression, which made it easy to inspect the data in ImageJ (via [n5-ij](https://github.com/saalfeldlab/n5-ij)) and to write `nrrd` and PNG exports efficiently.
We agree that keeping several versions is inefficient; the `zarr` files have since been deleted, since they can be regenerated bit-for-bit by re-running the notebook.

#### R2.17

> Extraction of features of interest
> Does the processing time needed to segment a single fish correspond to the 10-15 minutes stated in Table 1.?
> For 51 specimens, that would represent 12.5h of manual interventions and it should be noted.
> An estimate of the time needed to train the model in Biomedisa should be provided.
> Those combined should be accounted for in the pipeline segmentation time indicated in Table 1.

#### R2.18

> Landmarking of Models
> The authors should explain why they did not use the SlicerMorph extension to place the landmarks and chose to use a proprietary software like Stratovan.
> For better practices, it is preferred to stay within the same software environnement, it would prevent input/output errors and save time in data transfer.
> This is especially confusing as 3Dslicer is later used for ensuring equal distances.
> And Stratovan is not free/open-source.

We agree with the reviewer about generally preferring open-source pipelines for analyses.
In this case, Stratovan in particular was used for the template-import to speed up fixed landmark placements (which far outperformed ALPACA/MALPACA modules in Slicer in our tests), with the python-scriptable elements of Slicer to assist with the semilandmarks.
#### R2.19

> Line 247: The total number of projections and reconstructions are not meaningful and should be removed.

We prefer to keep these numbers, as they document the total amount of data acquired.

#### R2.20

> 4000 images in a CTscan is far too much when only 2000 images contain the region of interest of the morphometrics study, please consider CTscanning only this ROI or running the post-processing on a crop in the anterior-posterior direction if the scan of the whole specimen is needed.

Please see our response to R2.10. The case study itself was performed on datasets cropped to the head region.

#### R2.21

> Line 261: The justification that ImageJ could not be used is wrong.
> There is no need to use Crop3D in this workflow as the authors only crop in XY and not in Z direction.
> The workflow can be done automatically and would be reproducible with a similar approach the authors used in the detect_fish_position function:
>
> - import the images as a virtual stack into ImageJ,
> - run a Z projection of maximum intensity, threshold it to get a binary image
> - run an Analyse particles with a pixel size limit to discard the small speckels
> - add the results as ROIs in the ROI manager (each fish is a ROI with a label)
> - for each ROI, compute its bounding box, add a margin and record its coordinates in a log file for reproductibility
> - transfer the ROI on the virtual stack and crop
> The RAM usage would be up to the cropped subvolume weight, that can be handled with a standard workstation.
> Still it has to be done 6 times, so it should be run in a macro or a plugin to save operator time.

We thank the reviewer for this detailed suggestion and agree that our original statement was too strong.
Since we only crop in XY, a Fiji macro working on a virtual stack (MIP, thresholding, *Analyze Particles*, cropping each ROI with a margin and logging the coordinates) would extract the fish reproducibly and with modest memory requirements.
This is essentially the algorithm our pipeline implements, and we rewrote the paragraph in the Results accordingly ([L##]).

We implemented it in Jupyter notebooks because cropping is only one of the steps from a multi-specimen scan to an identified single-fish dataset:

- regions are assigned to compartments by their angle and mapped to fish IDs; a cropped stack without a reliable fish ID is of no use for the analysis;
- for each fish, the pipeline writes the `nrrd` dataset with the voxel size in its header, a log file with the crop coordinates, and control images;
- the detection uses the same MIPs as the quality control in the preview notebook;
- all 38 scans are processed in one batch; only two scans needed user input (one with five fish, one in a three-compartment holder).

A Fiji macro could be extended to do all this, but would amount to a reimplementation of the pipeline; our contribution is the automation and documentation of the full chain, not the choice of tool for cropping.

#### R2.22

- The detected regions are assigned to the compartments of the sample holder based on their angle around the rotation axis, and then mapped to the fish IDs from the lab book.
  A cropped stack without a reliable fish ID is of no use for the later analysis.
- For each fish, the pipeline writes the cropped dataset as `nrrd` with the voxel size in the header, a log file with the crop coordinates in the original dataset, and control images showing the detected regions and their assignment.
- The MIPs used for the detection are the same ones used in the preview notebook for quality control, so the whole chain from reconstructions to single-fish datasets runs on the same data in one reproducible, documented environment.
- All 38 scans are processed in one batch without user interaction.
  Technically, user interaction was necessary for 2 of the 38 scans, since in one scan we were able to only mount fish into 5 of the 6 petals due to the size of the fish and we scanned the last batch in a sample holder with only three petals (with two remaining fish from the batch and the one that was too big from the 5-of-6-petals scan).

A Fiji macro could be extended to do all this, but would then amount to a reimplementation of our pipeline in a different language.
We see the main contribution of our work in automating and documenting the full chain, not in the choice of a particular tool for the cropping step.

> The indication of an extra weight in Fiji might come from the software working with .tif format by default and not taking into account the compression in the .png format.

#### R2.23

> Table 1. The comment on how it would have been completely infeasible to scan each fish separately should be more salient than a side note in a table.
>In my opinion, it is the main motivation behind the authors’ developments.

#### R2.24

> When estimating the time needed to scan a single fish, the duration would not be the same as a batch because one would need less than 3600 projections per scan.

The duration of the scan would be the same, as the number of projections is given *per* stack (360° scanning rotation at 0.1° rotation step).
Since we would have needed to cover a smaller *lateral* field of view for a scan of a single fish, we could have either increased the rotation step to really reduce the scanning time by acquiring less projections, or increase the resolution of the scan by decreasing the distance of the object to the source.
Since such a reduction would also decrease the vertical field of view, we would have needed to acquire more stacks to cover the whole length of the fish.

#### R2.25


Technically, one single fish would fit into a FOV even smaller than half the chosen width.
In pilot experiments we found that we need to scan the fish with a voxel size of smaller than 20 µm to safely resolve the features of interest.
Since we also *wanted* to have tomographic scans of the whole anteroposterior length of the fish (for follow-up studies) we would have needed to acquire the so-called stacked scans of the fish anyways, as the single fish are well approximated by a long and thin cylinder, and such a cylinder cannot be scanned at 20 µm otherwise.
The amount of stacks limits the field of view of the scan in the chosen (and ideal) scanning configuration for the fish.
As a consequence, we were able to "fill" the *lateral* field of view of the machine with more fish, e.g. by filling a multi-specimen sample holder with several fish, and acquiring the data of many (6) fish together in one scan.
#### R2.26

> Can the authors explain what is included in the 17 minutes manual time needed to split a single fish scan of a single fish ?

We loaded the PNG stack of the reconstructions of one multi-specimen scan in Fiji, generated the axial MIP and then used the selection tool to mark rectangular regions for each fish on it.
We then transferred the coordinates to the full stack, cropped and saved each region.
Repeating this step 6 times for one dataset and all the steps for another dataset took us about 35 minutes, i.e. about 17 minutes per scan.

#### R2.27

> Line 290: It would be great to provide the average size of a cropped .nrrd dataset for a single fish.

Please see our response to R1.15.
The 215 `nrrd` files total 385 GB, with a median of 1.65 GB per fish (range 0.6--6.2 GB); dataset size depends on fish length and on its tilt in the holder.
This is now given in the Results ([L##]).

#### R2.28

> Line 293: The sentence “ This relatively simple segmentation was sufficient to extract all of the features we analyzed further and we did not have to employ more advanced thresholding methods in our separation pipeline “ is confusing.
>The separation pipeline is used to get the subvolumes, there is no extraction of features with the multi-level thresholding in this method, only a rendering.
>The extraction of features, a.k.a the segmentation process, is later done in 3Dslicer.

## R2.29

> Figure 12: There is a typo with a double The.

#### R2.30

> Line 376: In order to make the pipeline reproductible for larger or more dense specimens:
>
> - The separation process should only rely on contrast between the specimen and a radio-transparent sample holder, or the sample holder should be designed differently to prevent the wrong labeling of the separation process.
> - The thresholding should be robust enough to encompass a shift to different pixel values for the region of interest.
> Those are the expectations to rightfully claim that the pipeline is replicable and clade-agnostic as stated in the abstract.
> The authors should consider the amount of revisions needed to achieve this statement or correct the statement with general guidelines on what would be the limitations of the pipeline (dimensions of the specimens, conservation (dry vs in solution), only vertebrates, etc.).
> I would recommand minor revisions and a more restricted description of the taxonomic groups that the pipeline can handle in the conclusion.

The separation step is *not* relying on the contrast between the specimen and a radio-transparent sample holder, but only relying on the contrast between the specimens and the background.
The sample holder we used is a UV-hardened, 3D-printed polymer which has approximately the same density as the soft tissue of the fish, which we were *not* interested in in this study.
As long as the individual specimen are possible to be detected on the top-down axial MIP image, our pipeline can separate them out of the multi-specimen scan.

Since updating the assignment of detected sample region to angular region in the sample holder the whole pipeline generalizes even more to any sample holder whose compartments are arranged at known angles around the rotation axis.
As long as the multiple specimen *centers* can be separated on the axial MIP image, their cropped regions can be extracted from the multi-specimen scan (with the detected outline of the region plus a buffer, if necessary).
We added details on the clade-agnosticity (if that's even a word) in the discussion section.

## References
