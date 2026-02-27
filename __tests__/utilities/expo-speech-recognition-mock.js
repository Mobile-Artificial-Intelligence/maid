const listener = { remove: jest.fn() };

const ExpoSpeechRecognitionModule = {
  getPermissionsAsync: jest.fn().mockResolvedValue({ granted: true, canAskAgain: false }),
  requestPermissionsAsync: jest.fn().mockResolvedValue({ granted: true }),
  start: jest.fn(),
  stop: jest.fn(),
  addListener: jest.fn().mockReturnValue(listener),
};

module.exports = { ExpoSpeechRecognitionModule };
