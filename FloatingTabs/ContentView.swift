//
//  ContentView.swift
//  FloatingTabs
//
//  Created by Rob Sturcke on 1/26/24.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var tabModel: TabModel = .init()
  @Environment(\.controlActiveState) private var state
  
  var body: some View {
    TabView(selection: $tabModel.activeTab) {
      Text("Home View")
        .tag(Tab.home)
        .background(HideTabBar())
      
      Text("Favorites View")
        .tag(Tab.favorites)
      
      Text("Notifications View")
        .tag(Tab.notifications)
      
      Text("Settings View")
        .tag(Tab.settings)
    }
    .customOnChange(value: state) { newValue in
      if newValue == .key {
        tabModel.addTabBar()
      }
    }
  }
}

extension View {
  @ViewBuilder
  func customOnChange(value: ControlActiveState, result: @escaping (ControlActiveState) -> ()) -> some View {
    if #available(macOS 14, *) {
      self
        .onChange(of: value) { oldValue, newValue in
          result(newValue)
        }
    } else {
      self
        .onChange(of: value, perform: result)
    }
  }
  
  @ViewBuilder
  func windowBackground() -> some View {
    if #available(macOS 14, *) {
      self
        .background(.windowBackground)
    } else {
      self
        .background(.background)
    }
  }
}

#Preview {
  ContentView()
}

class TabModel: ObservableObject {
  @Published var activeTab: Tab = .home
  @Published private(set) var isTabBarAdded: Bool = false
  
  private let id: String = UUID().uuidString
  
  func addTabBar() {
    guard !isTabBarAdded else { return }
    
    if let applicationWindow = NSApplication.shared.mainWindow {
      let customTabBar = NSHostingView(rootView: FloatingTabBarView().environmentObject(self))
      let floatingWindow = NSWindow()
      floatingWindow.styleMask = .borderless
      floatingWindow.contentView = customTabBar
      floatingWindow.backgroundColor = .clear
      floatingWindow.title = id
      let windowSize = applicationWindow.frame.size
      let windowOrigin = applicationWindow.frame.origin
      
      floatingWindow.setFrameOrigin(.init(x: windowOrigin.x - 50, y: windowOrigin.y + (windowSize.height - 150) / 2))
      
      applicationWindow.addChildWindow(floatingWindow, ordered: .above)
    } else {
      print("WINDOW NOT FOUND")
    }
  }
}

enum Tab: String, CaseIterable {
  case home = "house.fill"
  case favorites = "suit.heart.fill"
  case notifications = "bell.fill"
  case settings = "gearshape"
}

fileprivate struct FloatingTabBarView: View {
  @EnvironmentObject private var tabModel: TabModel
  
  var body: some View {
    VStack(spacing: 0) {
      
    }
    .frame(width: 45, height: 150)
    .windowBackground()
    .clipShape(.capsule)
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(width: 50)
    .contentShape(.capsule)
  }
}

fileprivate struct HideTabBar: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView {
    return .init()
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
      if let tabView = nsView.superview?.superview?.superview as? NSTabView {
        tabView.tabViewType = .noTabsNoBorder
        tabView.tabViewBorderType = .none
        tabView.tabPosition = .none
      }
    }
  }
}
