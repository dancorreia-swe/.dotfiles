#import <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

@interface KeyboardLayoutMonitor : NSObject
@property(strong, nonatomic) NSString *currentLayout;
@end

@implementation KeyboardLayoutMonitor

- (instancetype)init {
  self = [super init];
  if (self) {
    // Get initial layout
    [self updateCurrentLayout];

    // Send initial event
    [self triggerEvent];

    // Register for notifications
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(inputSourceChanged:)
               name:@"com.apple.Carbon."
                    @"TISNotifySelectedKeyboardInputSourceChanged"
             object:nil];

    [[NSDistributedNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(inputSourceChanged:)
               name:@"com.apple.HIToolbox.source.selected"
             object:nil];
  }
  return self;
}

- (void)updateCurrentLayout {
  TISInputSourceRef currentSource = TISCopyCurrentKeyboardInputSource();
  if (currentSource) {
    CFStringRef sourceName = (CFStringRef)TISGetInputSourceProperty(
        currentSource, kTISPropertyLocalizedName);
    if (sourceName) {
      self.currentLayout = (__bridge NSString *)sourceName;
    }
    CFRelease(currentSource);
  }
}

- (void)inputSourceChanged:(NSNotification *)notification {
  NSString *previousLayout = self.currentLayout;
  [self updateCurrentLayout];

  // Only trigger if layout actually changed
  if (![self.currentLayout isEqualToString:previousLayout]) {
    [self triggerEvent];
  }
}

- (void)triggerEvent {
  NSString *command = [NSString
      stringWithFormat:
          @"sketchybar --trigger keyboard_layout_changed layout=\"%@\"",
          self.currentLayout];
  system([command UTF8String]);
}

@end

int main() {
  @autoreleasepool {
    KeyboardLayoutMonitor *monitor = [[KeyboardLayoutMonitor alloc] init];
    [[NSRunLoop currentRunLoop] run];
  }
  return 0;
}
