#Code to work in Python to automatically resample curves using Slicer module. 

import vtk
import slicer
import os


#Set working directory 
os.chdir('Your\\Path\\Here')

#filePath = "_FG.X23.009_PO.mrk.json"

####In this case, we have hard-coded the resampling points based on the curve name for each file. The resampling points are as follows:
#Curve1: 21
#Curve2: 21
#Curve3: 16
#Curve4: 16
#Curve5: 21
#Curve6: 16
#Curve7: 16


####Main Loops

def resample_curve(resampleNumber=31, nodeName="OC_Test", newNodeName="resampledCurveTest"):
  #Function to get the curve node, with a set default resample number of 31 points, and default node names for the original and new curve nodes from the Slicer module.
  print(nodeName)
  curve = getNode(nodeName)
  # Get current points from the curve
  currentPoints = curve.GetCurvePointsWorld()
    
  # Create a new vtkPoints object to store resampled points
  newPoints = vtk.vtkPoints()
  
  # Calculate the sample distance
  sampleDist = curve.GetCurveLengthWorld() / (resampleNumber - 1)
    
  # Resample the points
  closedCurveOption = 0
  curve.ResamplePoints(currentPoints, newPoints, sampleDist, closedCurveOption)
    
  # Create a new vector and point array
  vector = vtk.vtkVector3d()
  pt = [0, 0, 0]
    
  # Add a new curve node to the scene
  resampledCurve = slicer.mrmlScene.AddNewNodeByClass("vtkMRMLMarkupsCurveNode", newNodeName)
    
  # Add resampled points to the new curve node
  for controlPoint in range(newPoints.GetNumberOfPoints()):
      newPoints.GetPoint(controlPoint, pt)
      vector[0] = pt[0]
      vector[1] = pt[1]
      vector[2] = pt[2]
      resampledCurve.AddControlPoint(vector)


def main_loop (directory_path):
  #Main loop to iterate through the files in the specified directory, resample curves based on their names, and save the resampled curves.
  directory = directory_path
  for filename in os.listdir(directory):
    #Print the filename being processed for debugging purposes. (CAN BE SILENCED IF NOT NEEDED)
    print(filename)
    if filename.endswith('.json'):
      file_path = os.path.join(directory, filename)
      newname = 'RESAMPLED_' + filename
      new_path = os.path.join(directory, newname)
      if "Curve1" in filename or "Curve2" in filename or "Curve5" in filename:
        print("Resampled with 21 points!")
        Curve = slicer.util.loadMarkups(file_path)
        resample_curve(21, filename.removesuffix(".mrk.json"), newname.removesuffix(".mrk.json"))
        Savenode = slicer.util.getNode(newname.removesuffix(".mrk.json"))
        Storage_Node = Savenode.CreateDefaultStorageNode()
        Storage_Node.SetFileName(new_path)
        Storage_Node.WriteData(Savenode)
        slicer.mrmlScene.RemoveNode(Savenode)
        delnode = slicer.util.getNode(filename.removesuffix(".mrk.json"))
        slicer.mrmlScene.RemoveNode(delnode)
        print(f"Processed {file_path} and saved results to {new_path}")
      elif "Curve3" in filename or "Curve4" in filename or "Curve6" in filename or "Curve7" in filename:
        print("Resampled with 16 points!")
        Curve = slicer.util.loadMarkups(file_path)
        resample_curve(16, filename.removesuffix(".mrk.json"), newname.removesuffix(".mrk.json"))
        Savenode = slicer.util.getNode(newname.removesuffix(".mrk.json"))
        Storage_Node = Savenode.CreateDefaultStorageNode()
        Storage_Node.SetFileName(new_path)
        Storage_Node.WriteData(Savenode)
        slicer.mrmlScene.RemoveNode(Savenode)
        delnode = slicer.util.getNode(filename.removesuffix(".mrk.json"))
        slicer.mrmlScene.RemoveNode(delnode)
        print(f"Processed {file_path} and saved results to {new_path}")


#Run it all
main_loop ("Folder_Of_Landmarks_Here")
