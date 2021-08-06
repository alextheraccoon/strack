# STRACK

STRACK is a mobile application that allows establishing a connection to and collecting data from sensors embedded in the eSense earbuds [1] (shown in Figure 1). STRACK is implemented in Flutter [2] using the eSense Flutter plugin presented in [3]. The name STRACK stands for “S-tudies” or “S-ession” TRACK-ing. The main features of the application are:

*	Creating an account (Figure 2)
*	Connecting to eSense earbuds via Bluetooth and starting/ending a session (Figure 3)
*	At the end of a session the application asks for reporting the type of activity performed during the recorded session (Figure 4).
*	Collecting data from accelerometer and gyroscope sensors and storing in the local database of the app.
*	Sensor data visualizations (Figure 5).
*	Uploading the data to a remote data storage (e.g., SwitchDrive, Google Drive)

<p align="middle">
  <img src="https://user-images.githubusercontent.com/36417871/128494936-e1422495-bd79-4818-9571-1f58a895e8dc.png" width="700" />
</p>

<p align="middle">
  <img src="https://user-images.githubusercontent.com/36417871/128491783-ea9c100b-e30c-4f26-a267-a99ca227ccaf.jpg" width="300" />
  <img src="https://user-images.githubusercontent.com/36417871/128491827-d8190e1e-5ec7-4dde-85c9-5dd0fd7cab3d.jpg" width="300" /> 
</p>
<p align="middle">
  <img src="https://user-images.githubusercontent.com/36417871/128491885-483272a3-8e19-4348-825e-4808bf8b4b5a.jpg" width="300" />
  <img src="https://user-images.githubusercontent.com/36417871/128491960-d8f65c76-585c-4551-b1c8-48a15b8e6251.jpg" width="300" /> 
</p>

An example dataset collected with STRACK is presented in the paper below and is available upon request. If you have any questions regarding the app or for requesting the dataset collected with the app, please do not hesitate to contact us at silvia.santini@usi.ch. If you use the app or the dataset, please cite the paper below:

* S. Gashi, A. Saeed, A. Vicini, E. Di Lascio, and S. Santini: "Hierarchical Classification and Transfer Learning to Recognize Head Gestures and Facial Expressions Using Earbuds". In: Proceedings of the ACM International Conference on Multimodal Interaction (ICMI 2021), October 2021. 9 pages.

[1] eSense. https://www.esense.io 

[2] Flutter. https://flutter.dev 

[3] eSense Flutter Plugin. https://pub.dev/packages/esense_flutter 


