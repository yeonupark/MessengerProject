//
//  OnboardingView.swift
//  MessengerProject
//
//  Created by Yeonu Park on 2024/01/07.
//

import SwiftUI
import KakaoSDKUser
import AuthenticationServices

struct OnboardingView: View {
    
    @Binding var isRootViewOnboardingView: Bool
    @Binding var isNewUser: Bool
    
    @State var isShowingBottomSheet = false
    @State var isShowingSignUpView = false
    @State var isShowingLoginView = false
    
    var body: some View {
        
        ZStack {
            ColorSet.Background.primary
                .ignoresSafeArea()
            VStack(alignment: .center) {
                
                Text("에브리미닛을 사용하여 간편하게 \n팀원들과 소통해보세요! 👨‍💻👩‍💻")
                    .multilineTextAlignment(.center)
                    .fontWithLineHeight(font: Typography.title1.font, lineHeight: Typography.title1.lineHeight)
                    .frame(width: 345, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding(.top, 39)
                
                Image(.onboarding).resizable()
                    //.frame(width: 368, height: 368)
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 89, leading: 12, bottom: 0, trailing: 12))
                
                Button(action: {
                    withAnimation {
                        isShowingBottomSheet.toggle()
                        isShowingSignUpView = false
                        isShowingLoginView = false
                    }
                }, label: {
                    Image(.startButton).resizable().aspectRatio(contentMode: .fit)
                        //.frame(width: 345, height: 44)
                        .padding(EdgeInsets(top: 153, leading: 24, bottom: 24, trailing: 24))
                })
                .sheet(isPresented: $isShowingBottomSheet, content: {
                    if isShowingLoginView {
                        LoginView(isRootViewOnboardingView: $isRootViewOnboardingView, isNewUser: $isNewUser, isShowingLoginView: $isShowingLoginView)
                            .presentationDragIndicator(.visible)
                    }
                    else if isShowingSignUpView {
                        SignUpView(isRootViewOnboardingView: $isRootViewOnboardingView, isNewUser: $isNewUser, isShowingBottomSheet: $isShowingBottomSheet)
                            .presentationDragIndicator(.visible)
                    } else {
                        loginSelectionView(isRootViewOnboardingView: $isRootViewOnboardingView, isNewUser: $isNewUser, isShowingSignUpView: $isShowingSignUpView, isShowingLoginView: $isShowingLoginView)
                            .presentationCornerRadius(20)
                            .presentationDetents([.height(290)])
                            .presentationDragIndicator(.visible)
                    }
                })
                
            }
        }
    }
}

struct loginSelectionView: View {
    
    @ObservedObject var viewModel = SocialLoginViewModel()
    
    @Binding var isRootViewOnboardingView: Bool
    @Binding var isNewUser: Bool
    
    @Binding var isShowingSignUpView: Bool
    @Binding var isShowingLoginView: Bool
    
    var body: some View {
        
        ColorSet.Brand.white
        
        VStack {
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Apple Login Successful")
                    switch authResults.credential{
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        
                        let fullName = appleIDCredential.fullName
                        let name =  (fullName?.givenName ?? "") + (fullName?.familyName ?? "")
                        let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
                        
                        viewModel.appleLogin(token: idToken ?? "", nickname: name) { result in
                            if result {
                                isRootViewOnboardingView = false
                                isNewUser = false
                            }
                        }
                    default:
                        break
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    print("error")
                }
            }
            .signInWithAppleButtonStyle(.white)
            .overlay(alignment: .center) {
                LoginButtonImage(buttonImage: Image(.appleLogin), topPadding: 0)
            }
            .frame(width: 323, height: 44)
            .padding(.top, 42)
            
            Button(action: {
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        print("카카오로그인 성공 !")
                        if let token = oauthToken {
                            viewModel.kakaoLogin(token: token.accessToken) { result in
                                if result {
                                    isRootViewOnboardingView = false
                                    isNewUser = false
                                }
                            }
                        }
                    }
                    
                }
            }, label: {
                LoginButtonImage(buttonImage: Image(.kakaoLogin), topPadding: 12)
            })
            
            Button(action: {
                isShowingLoginView = true
            }, label: {
                LoginButtonImage(buttonImage: Image(.emailLogin), topPadding: 12)
            })
            
            HStack {
                Text("또는")
                    .foregroundColor(ColorSet.Brand.black)
                Button(action: {
                    isShowingSignUpView = true
                }, label: {
                    Text("새롭게 회원가입 하기")
                        .foregroundColor(ColorSet.Brand.orange)
                })
                
            }
            .fontWithLineHeight(font: Typography.title2.font, lineHeight: Typography.title2.lineHeight)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
        }
    }
    
}

struct LoginButtonImage: View {
    
    var buttonImage: Image
    var topPadding: CGFloat
    
    var body: some View {
        buttonImage.resizable().aspectRatio(contentMode: .fit)
            .frame(width: 323, height: 44)
            .padding(EdgeInsets(top: topPadding, leading: 16, bottom: 0, trailing: 16))
    }
}
