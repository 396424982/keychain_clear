GCC_BIN=`xcrun --sdk iphoneos --find gcc`
SDK=`xcrun --sdk iphoneos --show-sdk-path`
#support iPhone 3GS and above, delete armv6 to avoid SDK error
ARCH_FLAGS=-arch armv7 -arch armv7s -arch arm64

LDFLAGS	=\
	-F$(SDK)/System/Library/Frameworks/\
	-F$(SDK)/System/Library/PrivateFrameworks/\
	-framework UIKit\
	-framework CoreFoundation\
	-framework Foundation\
	-framework CoreGraphics\
	-framework Security\
	-lobjc\
	-lsqlite3\
	-bind_at_load

GCC_ARM = $(GCC_BIN) -Os -Wimplicit -isysroot $(SDK) $(ARCH_FLAGS)

default: main.o list
	@$(GCC_ARM) $(LDFLAGS) main.o -o keychain_clear
	ldid -Sentitlements.xml keychain_clear
	scp ./keychain_clear root@192.168.119.241:/

main.o: main.m
	$(GCC_ARM) -c main.m

clean:
	rm -f keychain_clear *.o

list:
	#security find-identity -pcodesigning
	#@printf '\nTo codesign, please run: \n\tCER="<40 character hex string for certificate>" make codesign\n'

codesign:
	codesign -fs "$(CER)" --entitlements entitlements.xml keychain_clear

