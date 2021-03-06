(function(exports) {

    // 注意
    // 这些代码只会执行一遍，对于某些可变的属性，尽量不要在此处定义，可以使用方法的形式
    // 属性的调用直接写就好，但是方法的调用，尾部记得加()

    // 获取window
    // cWindow = UIApp.keyWindow;

    // 根控制器
    // cRootVC = function() {
    //     return UIApp.keyWindow.rootViewController;
    // };

    // AppID
    // cAppId = [NSBundle mainBundle].bundleIdentifier;

    // 沙河路径
    // cShaHe = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    
    var invalidParamStr = 'Invalid parameter';
	var missingParamStr = 'Missing parameter';

	// app id
	CCAppId = [NSBundle mainBundle].bundleIdentifier;

	// mainBundlePath
	CCAppPath = [NSBundle mainBundle].bundlePath;

	// 沙河路径
	CCDocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

	// 缓存路径
	CCCachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]; 

	// 加载系统动态库
	CCLoadFramework = function(name) {
		var head = "/System/Library/";
		var foot = "Frameworks/" + name + ".framework";
		var bundle = [NSBundle bundleWithPath:head + foot] || [NSBundle bundleWithPath:head + "Private" + foot];
  		[bundle load];
  		return bundle;
	};

	// 主窗口
	CCKeyWin = function() {
		return UIApp.keyWindow;
	};

	// 根控制器
	CCRootVc =  function() {
		return UIApp.keyWindow.rootViewController;
	};

	// 找到显示在最前面的控制器
	var _CCFrontVc = function(vc) {
		if (vc.presentedViewController) {
        	return _CCFrontVc(vc.presentedViewController);
	    }else if ([vc isKindOfClass:[UITabBarController class]]) {
	        return _CCFrontVc(vc.selectedViewController);
	    } else if ([vc isKindOfClass:[UINavigationController class]]) {
	        return _CCFrontVc(vc.visibleViewController);
	    } else {
	    	var count = vc.childViewControllers.count;
    		for (var i = count - 1; i >= 0; i--) {
    			var childVc = vc.childViewControllers[i];
    			if (childVc && childVc.view.window) {
    				vc = _CCFrontVc(childVc);
    				break;
    			}
    		}
	        return vc;
    	}
	};

    // 获取最顶层控制器
	CCFrontVc = function() {
		return _CCFrontVc(UIApp.keyWindow.rootViewController);
	};

	// 递归打印UIViewController view的层级结构
	CCVcSubviews = function(vc) { 
		if (![vc isKindOfClass:[UIViewController class]]) throw new Error(invalidParamStr);
		return vc.view.recursiveDescription().toString(); 
	};

	// 递归打印最上层UIViewController view的层级结构
	CCFrontVcSubViews = function() {
		return CCVcSubviews(_CCFrontVc(UIApp.keyWindow.rootViewController));
	};

	// 获取按钮绑定的所有TouchUpInside事件的方法名
	CCBtnTouchUpEvent = function(btn) { 
		var events = [];
		var allTargets = btn.allTargets().allObjects()
		var count = allTargets.count;
    	for (var i = count - 1; i >= 0; i--) { 
    		if (btn != allTargets[i]) {
    			var e = [btn actionsForTarget:allTargets[i] forControlEvent:UIControlEventTouchUpInside];
    			events.push(e);
    		}
    	}
	   return events;
	};

	// CG函数
	CCPointMake = function(x, y) { 
		return {0 : x, 1 : y}; 
	};

	CCSizeMake = function(w, h) { 
		return {0 : w, 1 : h}; 
	};

	CCRectMake = function(x, y, w, h) { 
		return {0 : CCPointMake(x, y), 1 : CCSizeMake(w, h)}; 
	};

	// 递归打印controller的层级结构
	CCChildVcs = function(vc) {
		if (![vc isKindOfClass:[UIViewController class]]) throw new Error(invalidParamStr);
		return [vc _printHierarchy].toString();
	};

	


	// 递归打印view的层级结构
	CCSubviews = function(view) { 
		if (![view isKindOfClass:[UIView class]]) throw new Error(invalidParamStr);
		return view.recursiveDescription().toString(); 
	};

	// 判断是否为字符串 "str" @"str"
	CCIsString = function(str) {
		return typeof str == 'string' || str instanceof String;
	};

	// 判断是否为数组 []、@[]
	CCIsArray = function(arr) {
		return arr instanceof Array;
	};

	// 判断是否为数字 666 @666
	CCIsNumber = function(num) {
		return typeof num == 'number' || num instanceof Number;
	};

	var _CCClass = function(className) {
		if (!className) throw new Error(missingParamStr);
		if (CCIsString(className)) {
			return NSClassFromString(className);
		} 
		if (!className) throw new Error(invalidParamStr);
		// 对象或者类
		return className.class();
	};

	// 打印所有的子类
	CCSubclasses = function(className, reg) {
		className = _CCClass(className);

		return [c for each (c in ObjectiveC.classes) 
		if (c != className 
			&& class_getSuperclass(c) 
			&& [c isSubclassOfClass:className] 
			&& (!reg || reg.test(c)))
			];
	};

	// 打印所有的方法
	var _CCGetMethods = function(className, reg, clazz) {
		className = _CCClass(className);

		var count = new new Type('I');
		var classObj = clazz ? className.constructor : className;
		var methodList = class_copyMethodList(classObj, count);
		var methodsArray = [];
		var methodNamesArray = [];
		for(var i = 0; i < *count; i++) {
			var method = methodList[i];
			var selector = method_getName(method);
			var name = sel_getName(selector);
			if (reg && !reg.test(name)) continue;
			methodsArray.push({
				selector : selector, 
				type : method_getTypeEncoding(method)
			});
			methodNamesArray.push(name);
		}
		free(methodList);
		return [methodsArray, methodNamesArray];
	};

	var _CCMethods = function(className, reg, clazz) {
		return _CCGetMethods(className, reg, clazz)[0];
	};

	// 打印所有的方法名字
	var _CCMethodNames = function(className, reg, clazz) {
		return _CCGetMethods(className, reg, clazz)[1];
	};

	// 打印所有的对象方法
	CCInstanceMethods = function(className, reg) {
		return _CCMethods(className, reg);
	};

	// 打印所有的对象方法名字
	CCInstanceMethodNames = function(className, reg) {
		return _CCMethodNames(className, reg);
	};

	// 打印所有的类方法
	CCClassMethods = function(className, reg) {
		return _CCMethods(className, reg, true);
	};

	// 打印所有的类方法名字
	CCClassMethodNames = function(className, reg) {
		return _CCMethodNames(className, reg, true);
	};

	// 打印所有的成员变量
	CCIvars = function(obj, reg){ 
		if (!obj) throw new Error(missingParamStr);
		var x = {}; 
		for(var i in *obj) { 
			try { 
				var value = (*obj)[i];
				if (reg && !reg.test(i) && !reg.test(value)) continue;
				x[i] = value; 
			} catch(e){} 
		} 
		return x; 
	};

	// 打印所有的成员变量名字
	CCIvarNames = function(obj, reg) {
		if (!obj) throw new Error(missingParamStr);
		var array = [];
		for(var name in *obj) { 
			if (reg && !reg.test(name)) continue;
			array.push(name);
		}
		return array;
	};

})(exports);