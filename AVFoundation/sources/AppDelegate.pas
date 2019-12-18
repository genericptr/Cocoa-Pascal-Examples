{$mode objfpc}
{$modeswitch objectivec2}

unit AppDelegate;
interface
uses
	AVFoundation, CocoaAll;

type
	TAppDelegate = objcclass(NSObject, AVCaptureFileOutputDelegateProtocol, AVCaptureFileOutputRecordingDelegateProtocol, NSApplicationDelegateProtocol)
    private
      window: NSWindow;
      captureSession: AVCaptureSession;
  	public
      procedure prepareSession; message 'prepareSession';

      { NSApplicationDelegateProtocol }      
  		procedure applicationDidFinishLaunching(notification: NSNotification); message 'applicationDidFinishLaunching:';
      procedure applicationWillTerminate (notification: NSNotification); message 'applicationWillTerminate:';
      function applicationShouldTerminateAfterLastWindowClosed (sender: NSApplication): boolean; message 'applicationShouldTerminateAfterLastWindowClosed:';

      { AVCaptureFileOutputDelegate }
      function captureOutputShouldProvideSampleAccurateRecordingStart (captureOutput: AVCaptureOutput): objcbool; message 'captureOutputShouldProvideSampleAccurateRecordingStart:';

      { AVCaptureFileOutputRecordingDelegate }
      procedure captureOutput_didStartRecordingToOutputFileAtURL_fromConnections (captureOutput: AVCaptureFileOutput; fileURL: NSURL; connections: NSArray); message 'captureOutput:didStartRecordingToOutputFileAtURL:fromConnections:';
      procedure captureOutput_didFinishRecordingToOutputFileAtURL_fromConnections_error (captureOutput: AVCaptureFileOutput; outputFileURL: NSURL; connections: NSArray; error: NSError); message 'captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:';
 	end;

implementation
uses
  CocoaUtils;

{$assertions on}

function TAppDelegate.captureOutputShouldProvideSampleAccurateRecordingStart (captureOutput: AVCaptureOutput): objcbool;
begin
  result := true;
end;

procedure TAppDelegate.captureOutput_didStartRecordingToOutputFileAtURL_fromConnections (captureOutput: AVCaptureFileOutput; fileURL: NSURL; connections: NSArray);
begin
  writeln('did start recording '+fileURL.path.utf8string);
end;

procedure TAppDelegate.captureOutput_didFinishRecordingToOutputFileAtURL_fromConnections_error (captureOutput: AVCaptureFileOutput; outputFileURL: NSURL; connections: NSArray; error: NSError);
begin
  writeln('did finish recording');
end;

procedure TAppDelegate.prepareSession;
var
  devices: NSArray; 
  device: id;
  error: NSError;
  audioDevice,
  videoDevice: AVCaptureDevice;
  audioInput,
  videoInput: AVCaptureDeviceInput;
  fileOutput: AVCaptureMovieFileOutput;
  outputFileURL: NSURL;
  screenInput: AVCaptureScreenInput;
  screenCapture,
  videoCapture,
  audioCapture: boolean;
begin
  captureSession := AVCaptureSession.alloc.init;

  writeln('available devices:');
  devices := AVCaptureDevice.devices;
  for device in devices do
    begin
      writeln(string(device));
    end;

  // screen and video and mutually exclusive
  screenCapture := true;
  videoCapture := false;
  audioCapture := false;

  captureSession.beginConfiguration;
  captureSession.setSessionPreset(AVCaptureSessionPresetHigh);

  // audio device
  if audioCapture then
    begin
      audioDevice := AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio);
      Assert(audioDevice <> nil, 'audio device not available');

      audioInput := AVCaptureDeviceInput.deviceInputWithDevice_error(audioDevice, @error);
      Assert(audioInput <> nil, 'audio input not available '+string(error.localizedDescription));
      if captureSession.canAddInput(audioInput) then
        captureSession.addInput(audioInput);
    end;

  // video device
  if videoCapture then
    begin
      videoDevice := AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
      Assert(videoDevice <> nil, 'video device not available');

      videoInput := AVCaptureDeviceInput.deviceInputWithDevice_error(videoDevice, @error);
      Assert(videoInput <> nil, 'video input not available '+string(error.localizedDescription));
      if captureSession.canAddInput(videoInput) then
        captureSession.addInput(videoInput);
    end;

  // screen input
  if screenCapture then
    begin
      screenInput := AVCaptureScreenInput.alloc.initWithDisplayID(0);
      screenInput.setCapturesCursor(true);
      screenInput.setCapturesMouseClicks(true);
      if captureSession.canAddInput(screenInput) then
        captureSession.addInput(screenInput);
    end;

  // file output
  fileOutput := AVCaptureMovieFileOutput.alloc.init;
  fileOutput.setDelegate(self);
  if captureSession.canAddOutput(fileOutput) then
    captureSession.addOutput(fileOutput);

  captureSession.commitConfiguration();
  captureSession.startRunning();

  outputFileURL := NSURL.fileURLWithPath(string(NSHomeDirectory)+'/Desktop/test_video.mp4');
  // delete existing file or we won't record
  NSFileManager.defaultManager.removeItemAtURL_error(outputFileURL, nil);

  fileOutput.startRecordingToOutputFileURL_recordingDelegate(outputFileURL, self);
end;

function TAppDelegate.applicationShouldTerminateAfterLastWindowClosed (sender: NSApplication): boolean;
begin
  result := true;
end;

procedure TAppDelegate.applicationWillTerminate(notification: NSNotification);
begin
  captureSession.stopRunning;
end;

procedure TAppDelegate.applicationDidFinishLaunching(notification : NSNotification);
begin
	prepareSession; 
end;

end.