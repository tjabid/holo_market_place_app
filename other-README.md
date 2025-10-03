# Holo Mobile Coding Challenge

Build a small but polished e‑commerce app that consumes a public API. You have full freedom over UI/UX, feature scope, and architecture. Show us how you think, design, and build.

- Clean architecture
- Feature based development break down:
	- app structure setup - 3 story points
	- Product list - 5 story points
	- cart 
	- product details
	- search
	- unit tests
	- discounts
	- featured product
	- categories 

## 🎯 Goals
- Demonstrate clean, maintainable Flutter code and a sensible architecture.
- Deliver a smooth UI/UX with proper loading, error states, and empty states.
- Integrate with a real API and handle the common edge cases.

## 🔗 API
Use FakeStoreAPI:
- Website: https://fakestoreapi.com
- Endpoints you may use: `/products`, `/carts`, `/users`

You’re free to select which endpoints and flows to implement.

## ✅ Suggested Core Scope (flexible)
You can adjust scope based on your design decisions, but aim to cover most of:
- Product list: image, title, price, category, loading states
- Product details: description, add to cart
- Cart: view items, update quantity, remove item, totals
- Basic persistence for cart (e.g., local storage)
- Error handling and retry for API calls
- Support iOS and Android

### Break down

. Add to card accessible from everywhere
. Lottie animation
	- Product list: 
		image, title, price, category, loading states
		-> list of products
			-> Add to card
		Good to have	
			-> categories
			-> search
			-> overview modal on list page
			-> login and status of user
			-> add to favourite
			-> suggested products on details page

	- Product details: 	
		description, add to cart
	- Cart: view items, update quantity, remove item, totals
	- Basic persistence for cart (e.g., local storage)
	- Error handling 
	- retry for API calls
	- Support iOS and Android

## ✨ Bonus Ideas
- Shimmer/loading animations and tasteful page transitions
- Theme switcher (light/dark)
- Unit tests for business logic (and/or widget tests)
- Offline caching and graceful recovery
- Localization (at least 2 locales)

-> tracking and monitoring

## 🧱 Architecture & Guidelines
- Choose any state management you’re comfortable with (e.g., Riverpod, BLoC/Cubit).
- Keep a clear folder structure (data/domain/presentation or feature-first).
- Separate concerns: API clients, models, repositories, view models, widgets.
- Strive for testable units and cohesive modules.

## 📝 Evaluation Criteria
- UI/UX quality and usability
- API integration quality and error handling
- Branches & Commits
- Architecture decisions and code organization
- Readability, maintainability, and documentation
- Product sense and practicality

## 📦 Deliverables
Provide a GitHub repository with:
- Clear commit history and meaningful messages
- A short README covering:
	- Design choices
	- Architecture and state management decisions
	- Any trade‑offs or known limitations
- If the repo is private, invite: `@omarholo`

## 🎨 Design
Use any modern mobile UI style. You may take inspiration from a reference design (if you have one) or showcase your own taste. Keep it consistent and accessible.

## 📮 Submission
- Share the repository link and any additional notes.
- If you include environment-specific setup, document it clearly.

Good luck and have fun building! 🚀










# First

Build a small but polished e‑commerce app that consumes a public API. You have full freedom over UI/UX, feature scope, and architecture. Show us how you think, design, and build.

## 🎯 Goals
- Demonstrate clean, maintainable Flutter code and a sensible architecture.
- Deliver a smooth UI/UX with proper loading, error states, and empty states.
- Integrate with a real API and handle the common edge cases.

## 🔗 API
Use FakeStoreAPI:
- Website: https://fakestoreapi.com
- Endpoints you may use: `/products`, `/carts`, `/users`

You’re free to select which endpoints and flows to implement.

## ✅ Suggested Core Scope (flexible)
You can adjust scope based on your design decisions, but aim to cover most of:
. Add to card accessible from everywhere
. Lottie animation
- Product list: 
	image, title, price, category, loading states
	-> list of products
		-> Add to card
	Good to have	
		-> categories
		-> search
		-> overview modal on list page
		-> login and status of user
		-> add to favourite
		-> suggested products on details page

- Product details: 	
	description, add to cart
- Cart: view items, update quantity, remove item, totals
- Basic persistence for cart (e.g., local storage)
- Error handling 
- retry for API calls
- Support iOS and Android

## ✨ Bonus Ideas
- Shimmer/loading animations and tasteful page transitions
- Theme switcher (light/dark)
- Unit tests for business logic (and/or widget tests)
- Offline caching and graceful recovery
- Localization (at least 2 locales)

-> tracking and monitoring


## 🧱 Architecture & Guidelines
- Choose any state management you’re comfortable with (e.g., Riverpod, BLoC/Cubit).
- Keep a clear folder structure (data/domain/presentation or feature-first).
- Separate concerns: API clients, models, repositories, view models, widgets.
- Strive for testable units and cohesive modules.

## 📝 E 
- UI/UX quality and usability
- API integration quality and error handling
- Branches & Commits
- Architecture decisions and code organization
- Readability, maintainability, and documentation
- Product sense and practicality

## 📦 Deliverables
Provide a GitHub repository with:
- Clear commit history and meaningful messages
- A short README covering:
	- Design choices
	- Architecture and state management decisions
	- Any trade‑offs or known limitations
- If the repo is private, invite: `@omarholo`

## 🎨 Design
Use any modern mobile UI style. You may take inspiration from a reference design (if you have one) or showcase your own taste. Keep it consistent and accessible.

## 📮 Submission
- Share the repository link and any additional notes.
- If you include environment-specific setup, document it clearly.

Good luck and have fun building! 🚀

