
#ifndef __PROTOCONTROLLER_H__
#define __PROTOCONTROLLER_H__

#include <iostream>
#include "ProtoBaseApp.h"
#include "ProtoRootBall.h"
#include "ProtoGeomComposite.h" // new class to test - integrate in PBA eventually

using namespace ijg;

class ProtoController : public ProtoBaseApp {

public:
	void init();
	void run();
	void display();

	// Key and Mouse Events
	void keyPressed();
	void mousePressed();
	void mouseRightPressed();
	void mouseReleased();
	void mouseRightReleased();
	void mouseMoved();
	void mouseDragged();

	// Window Events
	void onResized();
	void onClosed();

	//ProtoPlane plane;
	//ProtoGeomComposite* pcg;
	Toroid t;
	//ProtoRootBall* pBall;
	ProtoPlane plane;
	Tube tube;

};

#endif //__PROTOCONTROLLER_H__
