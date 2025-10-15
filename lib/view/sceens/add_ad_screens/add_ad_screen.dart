import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/add_ad_repository.dart';
import '../../../view_model/Add_ad_new/ad_cubit.dart';
import '../../../view_model/Add_ad_new/ad_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_select.dart';

class AddAdScreen extends StatelessWidget {
  const AddAdScreen({super.key});

  static const categories = [
    'Cars',
    'Real Estate',
    'Jobs',
    'Electronics',
    'Mobiles',
    'Fashion',
    'Furniture',
    'Services',
  ];
  static const conditions = ['New', 'Like New', 'Used - Good', 'Used - Fair'];

  @override
  Widget build(BuildContext context) {
    final SupabaseClient client = Supabase.instance.client;
    final user = client.auth.currentUser;

    final email = user!.email;
    final phone = user.userMetadata?['phone_number'] ?? "Not Found Number";
    return BlocProvider(
      create: (_) => AddAdViewModel(repo: SupabaseRepository()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<AddAdViewModel, AddAdState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
              if (state.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ad published successfully')),
                );
              }
            },
            builder: (context, state) {
              final vm = context.read<AddAdViewModel>();
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Post New Ad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photos
                              const Text(
                                'Photos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: state.images.length < 10
                                    ? state.images.length + 1
                                    : state.images.length,
                                itemBuilder: (context, index) {
                                  if (index < state.images.length) {
                                    final file = state.images[index];
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(file),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () => vm.removeImage(index),
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // add button
                                    return GestureDetector(
                                      onTap: vm.pickImages,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add,
                                              size: 28,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'Add Photo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add up to 10 photos. First photo will be the cover image.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Title
                              CustomInput(
                                label: 'Title *',
                                hint: 'e.g., big printer',
                                onChanged: vm.setTitle,
                              ),
                              const SizedBox(height: 14),

                              // Category
                              // CustomSelect(
                              //   label: 'Category *',
                              //   items: categories,
                              //   value: state.category.isEmpty ? null : state.category,
                              //   onChanged: (v) => vm.setCategory(v ?? ''),
                              // ),
                              CustomInput(
                                label: 'Category *',
                                hint: 'Category your item in detail...',
                                onChanged: (v) => vm.setCategory(v),
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 14),

                              // Description
                              CustomInput(
                                label: 'Description *',
                                hint: 'Describe your item in detail...',
                                onChanged: vm.setDescription,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Minimum 20 characters',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Price
                              CustomInput(
                                label: 'Price *',
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 15, top: 15),
                                  child: Text(
                                    '\$',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                onChanged: vm.setPrice,
                              ),
                              const SizedBox(height: 14),

                              // Condition
                              CustomSelect(
                                label: 'Condition *',
                                items: conditions,
                                value: state.condition.isEmpty
                                    ? null
                                    : state.condition,
                                onChanged: (v) => vm.setCondition(v ?? ''),
                              ),
                              const SizedBox(height: 14),

                              // Location
                              CustomInput(
                                label: 'Location *',
                                hint: 'Enter your location',
                                onChanged: vm.setLocation,
                                prefixIcon: const Icon(
                                  Icons.place,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Contact
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomInput(
                                label: 'Phone Number ',
                                hint: phone.toString(),
                                readOnly:true,
                                onChanged: vm.setPhone,
                              ),
                              const SizedBox(height: 10),
                              CustomInput(
                                label: 'Email',
                                hint: email.toString(),
                                readOnly:true,
                                onChanged: vm.setEmail,
                              ),
                              const SizedBox(height: 16),

                              // Featured
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.cyan.shade100,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: state.featured,
                                      onChanged: (v) =>
                                          vm.setFeatured(v ?? false),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Make this ad featured',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Get 10x more visibility and reach more potential buyers',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            '+\$9.99',
                                            style: TextStyle(
                                              color: Colors.cyan,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 56),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom action bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            text: state.loading
                                ? 'Publishing...'
                                : 'Publish Ad',
                            onPressed: state.loading ? null : vm.publishAd,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
